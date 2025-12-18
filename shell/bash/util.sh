sshfs_mount(){
    sshfs \
        -o default_permissions \
        -o uid=$(id -u) \
        -o gid=$(id -g) \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3
    $1 $2
}
cheatsh() {
    curl -s "cht.sh/$1"
}

function ssh_copy_terminfo()
{
    infocmp -x xterm-ghostty | ssh "$1" 'mkdir -p ~/.terminfo && tic -o ~/.terminfo -'
}

function ssh_proxyjump()
{
    ssh -o ProxyJump=$1 $2
}

function fix_ssh_key()
{
    echo "Fixing SSH key permissions after git pull clone push..."
    chmod 700 ~/.ssh > /dev/null 2>&1 || true
    chmod 600 ~/.ssh/id_rsa > /dev/null 2>&1 || true
}

# A shell function to diagnose terminal and tmux configuration.
term_check() {
    # --- Helper variables for formatting ---
    local color_reset='\033[0m'
    local color_red='\033[0;31m'
    local color_green='\033[0;32m'
    local color_yellow='\033[0;33m'
    local color_blue='\033[0;34m'
    local color_bold='\033[1m'

    # --- Nested helper function to print check items ---
    _check_item() {
        local message=$1
        # Renamed 'status' to 'check_status' to avoid conflict with shell's read-only variable
        local check_status=$2
        local recommendation=$3
        local status_color

        case "$check_status" in
            "OK")   status_color=$color_green ;;
            "WARN") status_color=$color_yellow ;;
            "FAIL") status_color=$color_red ;;
            *)      status_color=$color_reset ;;
        esac

        printf "  %-40s [${status_color}%s${color_reset}]\n" "$message" "$check_status"
        if [[ -n "$recommendation" ]]; then
            printf "    └─ ${color_yellow}%s${color_reset}\n" "$recommendation"
        fi
    }

    # --- Main Script Logic ---
    echo -e "${color_bold}${color_blue}--- Terminal Environment Diagnostics ---${color_reset}\n"

    # 1. General Terminal Info
    echo -e "${color_bold}1. General Terminal Info${color_reset}"
    if [[ -n "$TERM" ]]; then
        _check_item "TERM variable is set to:" "'$TERM'"
    else
        _check_item "TERM variable is set:" "FAIL" "Your TERM environment variable is not set."
    fi

    # 2. Check for terminfo entry
    if infocmp "$TERM" >/dev/null 2>&1; then
        _check_item "Terminfo entry for '$TERM' found:" "OK"
    else
        _check_item "Terminfo entry for '$TERM' found:" "FAIL" "No terminfo entry found. Applications may not display correctly."
    fi

    echo -e "\n${color_bold}2. Color Support${color_reset}"

    # 3. Check 256-color support
    local num_colors
    num_colors=$(tput colors 2>/dev/null || echo 0)
    if [[ $num_colors -ge 256 ]]; then
        _check_item "256-color support (tput colors):" "OK" "Reported $num_colors colors."
    else
        _check_item "256-color support (tput colors):" "WARN" "Reported only $num_colors colors."
    fi

    # 4. Check True Color (RGB) support
    if [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]; then
        _check_item "COLORTERM is '$COLORTERM':" "OK" "Indicates terminal should support True Color."
    else
        _check_item "COLORTERM variable:" "WARN" "Not set to 'truecolor' or '24bit'. This is a common indicator for True Color support."
    fi

    # Visual test for True Color
    printf "  Performing visual True Color test...\n"
    printf "    └─ ${color_yellow}If you see a smooth gradient below, True Color is working.${color_reset}\n"
    awk 'BEGIN{
        s="/\\";
        for (colnum = 0; colnum < 78; colnum++) {
            r = 255 - (colnum*255/78);
            g = colnum*510/78;
            if (g>255) g = 510-g;
            b = colnum*255/78;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s", substr(s,colnum%2+1,1);
        }
        printf "\033[0m\n";
    }'

    echo -e "\n${color_bold}3. Tmux Specific Settings${color_reset}"

    # 5. Check if inside tmux and its settings
    if [[ -n "$TMUX" ]]; then
        _check_item "Currently inside a tmux session:" "OK"

        local tmux_default_term
        tmux_default_term=$(tmux show-options -gqv default-terminal)
        if [[ "$tmux_default_term" == "tmux-256color" || "$tmux_default_term" == "screen-256color" ]]; then
            _check_item "tmux 'default-terminal' setting:" "OK" "Set to '$tmux_default_term'."
        else
            _check_item "tmux 'default-terminal' setting:" "WARN" "Set to '$tmux_default_term'. For best color support, use 'tmux-256color'."
        fi

        local tmux_term_features
        tmux_term_features=$(tmux show-options -gqv terminal-features)
        if [[ "$tmux_term_features" == *":RGB"* || "$tmux_term_features" == *":Tc"* ]]; then
            _check_item "tmux RGB color passthrough:" "OK" "'terminal-features' includes an RGB/Tc definition."
        else
            _check_item "tmux RGB color passthrough:" "FAIL" "Missing RGB/Tc capability." "Add 'set -as terminal-features \",*:RGB\"' to your ~/.tmux.conf (replace * with your real TERM outside tmux)."
        fi
    else
        _check_item "Currently inside a tmux session:" "INFO" "Not inside tmux. Skipping tmux checks."
    fi

    echo -e "\n${color_bold}${color_blue}--- Diagnostics Complete ---${color_reset}\n"
}

####################################
# 检测是否通过 SSH 连接，且不在 tmux 中
# if [ -n "$SSH_TTY" ] && [ -z "$TMUX" ]; then
#     if infocmp xterm-ghostty >/dev/null 2>&1; then
#         export TERM=xterm-ghostty
#     else
#         export TERM=xterm-256color
#     fi
# fi

# auto start tmux
if command -v tmux >/dev/null 2>&1; then
    if [ -z "$TMUX" ] && [ -e ~/.tmux-auto-start ]; then
        tmux attach -t default || tmux new -s default
    fi
fi


set_local_proxy() {
    if [ -z "$1" ]; then
        echo "use port 7890 as default proxy port"
        local proxy_port=7890
    else
        local proxy_port="$1"
    fi

    local proxy_host="localhost"
    local proxy_addr="${proxy_host}:${proxy_port}"

    # 设置小写环境变量 (标准)
    export http_proxy="http://${proxy_addr}"
    export https_proxy="http://${proxy_addr}" # 对于许多本地代理工具，https也通过http协议代理
    export ftp_proxy="http://${proxy_addr}"

    # 设置大写环境变量 (兼容性考虑)
    export HTTP_PROXY="http://${proxy_addr}"
    export HTTPS_PROXY="http://${proxy_addr}"
    export FTP_PROXY="http://${proxy_addr}"

    echo "set proxy as ${proxy_addr} (http, https, ftp)."
}

unset_local_proxy() {
    unset http_proxy https_proxy ftp_proxy http_proxy https_proxy ftp_proxy
    echo "unset proxy."
}

# 判断操作系统类型
# used when not tun proxy
function set_system_proxy() {
    local proxyhost="${1:-127.0.0.1}"
    local proxyport="${2:-7890}"

    case "$(uname -s)" in
        Darwin)
            echo "Detected macOS"
            networksetup -setwebproxy "Wi-Fi" "$proxyhost" "$proxyport" >/dev/null 2>&1
            networksetup -setsecurewebproxy "Wi-Fi" "$proxyhost" "$proxyport" >/dev/null 2>&1
            echo "System proxy enabled for Wi-Fi on macOS."
            ;;
        Linux)
            # TODO
            echo "Detected Linux"
            echo "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac
}

function unset_system_proxy() {
    case "$(uname -s)" in
        Darwin)
            echo "Detected macOS"
            networksetup -setwebproxystate "Wi-Fi" off >/dev/null 2>&1
            networksetup -setsecurewebproxystate "Wi-Fi" off >/dev/null 2>&1
            echo "System proxy disabled for Wi-Fi on macOS."
            ;;
        Linux)
            echo "Detected Linux"
            unset http_proxy
            unset https_proxy
            echo "Proxy environment variables unset."
            ;;
        *)
            echo "Detected Linux"
            echo "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac
}

check_proxy_env_vars() {
    local required_vars=("http_proxy" "https_proxy" "ftp_proxy" "HTTP_PROXY" "HTTPS_PROXY" "FTP_PROXY")
    local missing=()
    local invalid_format=()

    for var in "${required_vars[@]}"; do
        local value=$(printenv "$var")
        if [ -z "$value" ]; then
            missing+=("$var")
        else
            if [[ ! "$value" =~ ^https?://localhost:[0-9]+$ ]]; then
                invalid_format+=("$var (值: $value)")
            fi
        fi
    done

    if [ ${#missing[@]} -eq 0 ] && [ ${#invalid_format[@]} -eq 0 ]; then
        echo "✅ 所有代理环境变量已正确设置。"
        return 0
    else
        if [ ${#missing[@]} -gt 0 ]; then
            echo "⚠️ 以下环境变量未设置: ${missing[*]}"
        fi
        if [ ${#invalid_format[@]} -gt 0 ]; then
            echo "⚠️ 以下环境变量格式错误: ${invalid_format[*]}"
        fi
        return 1
    fi
}

test_proxy_reachability() {
    local port=${HTTP_PROXY#*:*:}

    echo -n "⏳ 正在尝试连接到代理服务器 localhost:${port} ... "

    # 使用 Bash 的 /dev/tcp 特性测试端口连通性
    if bash -c "echo > /dev/tcp/localhost/$port" 2>/dev/null; then
        echo "✅ 成功。"
        return 0
    else
        echo "❌ 失败。请确认代理服务是否正在运行。"
        return 1
    fi
}

test_proxy_network() {
    local http_url="http://www.google.com"
    # local https_url="https://www.google.com "


    echo "⏳ 正在进行网络连接测试..."

    echo -n "🔍 测试 HTTP 代理 (${http_url})... "
    if curl -s -o /dev/null -w "%{http_code}" --proxy-insecure "$http_url" | grep -q "200"; then
        echo "✅ 成功。"
    else
        echo "❌ 失败。HTTP 代理可能无效。"
        return 1
    fi

    # echo -n "🔍 测试 HTTPS 代理 (${https_url})... "
    # if curl -s -o /dev/null -w "%{http_code}" --insecure "$https_url" | grep -q "200"; then
    #     echo "✅ 成功。"
    # else
    #     echo "❌ 失败。HTTPS 代理可能无效。"
    #     return 1
    # fi

    return 0
}

display_external_ip() {
    local url="http://ifconfig.me "
    echo "⏳ 正在获取当前出口 IP 地址（访问 $url ）..."
    echo $(curl -s "$url")
}

test_proxy_all() {
    echo "🚀 开始全面代理测试..."

    echo -e "\n1️⃣ 检查环境变量设置..."
    if check_proxy_env_vars; then
        echo "✅ 环境变量检查通过。"
    else
        echo "❌ 环境变量检查失败。"
        return 1
    fi

    echo -e "\n2️⃣ 测试代理服务器是否可达..."
    if test_proxy_reachability; then
        echo "✅ 代理服务器可达。"
    else
        echo "❌ 代理服务器不可达。"
        return 1
    fi

    echo -e "\n3️⃣ 测试网络连接..."
    if test_proxy_network; then
        echo "✅ 网络连接测试通过。"
    else
        echo "❌ 网络连接测试失败。"
        return 1
    fi

    echo -e "\n4️⃣ 当前出口 IP 地址:"
    display_external_ip

    echo -e "\n✅ 所有测试通过，代理配置似乎有效。"
}

# yazi

function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}


