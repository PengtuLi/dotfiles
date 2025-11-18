# Proxy management functions
# Environment proxy: set/unset/check

set_local_proxy() {
    if [ -z "$1" ]; then
        echo "use port 7890 as default proxy port"
        local proxy_port=7890
    else
        local proxy_port="$1"
    fi

    local proxy_host="localhost"
    local proxy_addr="${proxy_host}:${proxy_port}"

    export http_proxy="http://${proxy_addr}"
    export https_proxy="http://${proxy_addr}"
    export ftp_proxy="http://${proxy_addr}"
    export HTTP_PROXY="http://${proxy_addr}"
    export HTTPS_PROXY="http://${proxy_addr}"
    export FTP_PROXY="http://${proxy_addr}"

    echo "set proxy as ${proxy_addr} (http, https, ftp)."
}

unset_local_proxy() {
    unset http_proxy https_proxy ftp_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY
    echo "unset proxy."
}

set_system_proxy() {
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
            echo "Detected Linux"
            echo "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac
}

unset_system_proxy() {
    case "$(uname -s)" in
        Darwin)
            echo "Detected macOS"
            networksetup -setwebproxystate "Wi-Fi" off >/dev/null 2>&1
            networksetup -setsecurewebproxystate "Wi-Fi" off >/dev/null 2>&1
            echo "System proxy disabled for Wi-Fi on macOS."
            ;;
        Linux)
            echo "Detected Linux"
            unset http_proxy https_proxy
            echo "Proxy environment variables unset."
            ;;
        *)
            echo "Detected Linux"
            echo "Unsupported OS: $(uname -s)"
            return 1
            ;;
    esac
}
