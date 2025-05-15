set_local_proxy() {
    if [ -z "$1" ]; then
        echo "用法: proxyon <端口号>"
        echo "错误: 请提供本地代理的端口号."
        return 1
    fi

    local proxy_host="localhost"
    local proxy_port="$1"
    local proxy_addr="${proxy_host}:${proxy_port}"

    # 设置小写环境变量 (标准)
    export http_proxy="http://${proxy_addr}"
    export https_proxy="http://${proxy_addr}" # 对于许多本地代理工具，https也通过http协议代理
    export ftp_proxy="ftp://${proxy_addr}"

    # 设置大写环境变量 (兼容性考虑)
    export HTTP_PROXY="http://${proxy_addr}"
    export HTTPS_PROXY="http://${proxy_addr}"
    export FTP_PROXY="http://${proxy_addr}" 

    echo "set proxy as ${proxy_addr} (http, https, ftp)."
}

# 函数：取消本地代理环境变量的设置
# 用法：unset_local_proxy
unset_local_proxy() {
    unset http_proxy https_proxy ftp_proxy http_proxy https_proxy ftp_proxy
    echo "unset proxy."
}

alias sP=set_local_proxy
alias usP=unset_local_proxy
