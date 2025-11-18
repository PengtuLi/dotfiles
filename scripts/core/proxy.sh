#!/bin/bash

# Get the absolute path of the directory where the script is located
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

. $ROOT_DIR/scripts/lib/common.sh

# bash manager
# https://github.com/juewuy/ShellCrash
# systemd
# https://wiki.metacubex.one/startup/service/
#
# cp mihomo /usr/local/bin
# cp config.yaml /etc/mihomo
#
# start
# /usr/local/bin/mihomo -d /etc/mihomo
#
# /Users/tutu/Library/LaunchAgents
# launchctl start com.example.app
# launchctl stop com.example.app
#
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
#   <dict>
#   <key>Label</key>
#   <string>Clash</string>
#   <key>ProgramArguments</key>
#   <array><string>mihomo -d /etc/mihomo</string></array>
#   <key>RunAtLoad</key>
#   <true/>
#   </dict>
# </plist>

# config_web(){
#
#     local cmd_touch="mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled"
#     local cmd_touch2="touch /etc/nginx/sites-available/clash-ui"
#     local cmd_write='echo "
#     server {
#         listen 9090;
#
#         server_name localhost;
#
#         location / {
#             root /etc/mihomo/ui/;
#             index index.html;
#             try_files $uri $uri/ =404;
#         }
#     }" > /etc/nginx/sites-available/clash-ui'
#     cmd_ln="ln -s /etc/nginx/sites-available/clash-ui /etc/nginx/sites-enabled"
#     if which sudo &>/dev/null; then
#         cmd_touch="sudo ${cmd_touch}"
#         cmd_touch2="sudo ${cmd_touch2}"
#         cmd_write="sudo ${cmd_write}"
#         cmd_ln="sudo ${cmd_ln}"
#     fi
#
#     eval $cmd_touch
#     eval $cmd_touch2
#     eval $cmd_write
#     eval $cmd_ln
#
#
#
#


install_proxy(){
    cd $ROOT_DIR/

    read -p "---- update mihomo kernel? [y/n] " update_kernel_version
    if [[ "$update_kernel_version" == "y" ]]; then
        cd $ROOT_DIR/mihomo-clash
        update_kernel
        cd $ROOT_DIR
    fi

    local cmd
    if is_macos; then
        cmd="rm -f /usr/local/bin/mihomo && ln -s $ROOT_DIR/mihomo-clash/mihomo-darwin-arm64 /usr/local/bin/mihomo"
    elif is_linux; then
        cmd="rm -f /usr/local/bin/mihomo && ln -s $ROOT_DIR/mihomo-clash/mihomo-linux-amd64 /usr/local/bin/mihomo"
    fi

    cmd2="rm -rf /etc/mihomo && ln -s $ROOT_DIR/mihomo-clash/config /etc/mihomo"
    rm -rf ~/.config/mihomo && ln -sf $ROOT_DIR/mihomo-clash/config ~/.config/mihomo

    chmod +x mihomo-clash/mihomo-linux-amd64
    chmod +x mihomo-clash/mihomo-darwin-arm64

    if which sudo &>/dev/null; then
        sudo sh -c "$cmd"
        sudo sh -c "$cmd2"
    else
        sh -c "$cmd"
        sh -c "$cmd2"
    fi

    echo ${cmd}
    echo ${cmd2}


    echo "proxy use: alias sPP='sudo mihomo -d /etc/mihomo'"
    # read -p "---- config server kernel? [y/n] " config_web_ui
    # if [[ "$config_web_ui" == "y" ]]; then
    #     config_web
    # fi

}



update_kernel(){
    # GitHub 仓库信息
    OWNER="MetaCubeX"
    REPO="mihomo"

    # 获取最新 release 的 tag 版本号
    echo "正在获取最新版本号..."
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_VERSION" ]; then
        echo "❌ 无法获取最新版本号，请检查网络或仓库是否存在。"
        exit 1
    fi

    echo "✅ 最新版本为: ${LATEST_VERSION}"

    # 构建下载链接前缀
    BASE_URL="https://github.com/${OWNER}/${REPO}/releases/download/${LATEST_VERSION}"

    # 需要下载的文件列表
    FILES=(
        "mihomo-darwin-arm64-${LATEST_VERSION}.gz"
        "mihomo-linux-amd64-${LATEST_VERSION}.gz"
    )
    # 下载并处理每个文件
    for FILE in "${FILES[@]}"; do
        DOWNLOAD_URL="${BASE_URL}/${FILE}"
        echo "⬇️ 正在下载: ${DOWNLOAD_URL}"
        curl -L -o "./${FILE}" "${DOWNLOAD_URL}"

        if [ $? -ne 0 ]; then
            echo "❌ 下载失败: ${FILE}"
            continue
        fi

        # 解压文件
        ORIGINAL_FILE="${FILE%.gz}"
        echo "🔓 正在解压: ${FILE}"
        gunzip "./${FILE}"

        if [ $? -ne 0 ]; then
            echo "❌ 解压失败: ${FILE}"
            rm -f "./${FILE}"
            continue
        fi

        # 去掉版本号，重命名文件
        # 示例：mihomo-darwin-amd64-v1.19.9 → mihomo-darwin-amd64
        NEW_NAME=$(echo "${ORIGINAL_FILE}" | sed -E 's/-v[0-9]+\.[0-9]+\.[0-9]+$//')

        if [ "$NEW_NAME" != "$ORIGINAL_FILE" ]; then
            echo "🔄 重命名: ${ORIGINAL_FILE} → ${NEW_NAME}"
            mv "./${ORIGINAL_FILE}" "./${NEW_NAME}"
        else
            echo "⚠️ 未识别版本格式，跳过重命名: ${ORIGINAL_FILE}"
        fi
    done
    echo "🎉 所有文件下载并解压完成！"

}

install_macos_mihomo_service() {
    if ! is_macos; then
        echo "❌ 此函数仅支持 macOS"
        return 1
    fi

    if [ ! -x /usr/local/bin/mihomo ]; then
        echo "❌ /usr/local/bin/mihomo 不存在或不可执行"
        return 1
    fi

    if [ ! -d /etc/mihomo ]; then
        echo "❌ /etc/mihomo 配置目录不存在"
        return 1
    fi

    echo "⚙️  正在安装 mihomo 系统服务..."

    # 创建日志文件
    sudo mkdir -p /var/log
    sudo touch /var/log/mihomo.log /var/log/mihomo-error.log
    sudo chown root:wheel /var/log/mihomo*
    sudo chmod 644 /var/log/mihomo*

    # 写入 plist
    sudo tee /Library/LaunchDaemons/com.mihomo.service.plist > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mihomo.service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/mihomo</string>
        <string>-d</string>
        <string>/etc/mihomo/</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ThrottleInterval</key>
    <integer>5</integer>
    <key>UserName</key>
    <string>root</string>
    <key>GroupName</key>
    <string>wheel</string>
    <key>StandardOutPath</key>
    <string>/var/log/mihomo.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/mihomo-error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>HOME</key>
        <string>/var/root</string>
        <key>USER</key>
        <string>root</string>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>LANG</key>
        <string>en_US.UTF-8</string>
    </dict>
</dict>
</plist>
EOF

    # 设置权限
    sudo chown root:wheel /Library/LaunchDaemons/com.mihomo.service.plist
    sudo chmod 644 /Library/LaunchDaemons/com.mihomo.service.plist

    # 重新加载服务
    sudo launchctl unload /Library/LaunchDaemons/com.mihomo.service.plist 2>/dev/null || true
    sudo launchctl load /Library/LaunchDaemons/com.mihomo.service.plist

    # 启动服务
    sudo launchctl start com.mihomo.service

    # 检查是否运行
    if sudo launchctl list | grep -q "com.mihomo.service"; then
        echo "✅ 服务 mihomo 已创建并启动"
    else
        echo "⚠️  服务启动失败，请查看日志：/var/log/mihomo-error.log"
        return 1
    fi
}

install_linux_mihomo_service(){

    sudo tee /etc/systemd/system/mihomo.service > /dev/null << 'EOF'
[Unit]
Description=Mihomo Proxy
After=network.target

[Service]
Type=simple
ExecStart=mihomo -d /etc/mihomo
Restart=always
UMask=0002

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now mihomo
    echo "✅ 服务 mihomo 已创建并启动"
}

install_proxy
if [[ "$(get_platform)" == "osx" ]]; then
    install_macos_mihomo_service
elif [[ "$(get_platform)" == "linux" ]] && is_arch_linux; then
    echo "archlinux 安装mihomo systemd服务"
    install_linux_mihomo_service
else
    echo "未安装mihomo系统服务，请手动启动"
fi
