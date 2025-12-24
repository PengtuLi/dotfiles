cheatsh() {
    curl -s "cht.sh/$1"
}

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


