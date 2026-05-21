#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

EASYTIER_DIR="$ROOT_DIR/easytier"

install_SMB(){

    # nas
    sudo chmod 644 $ROOT_DIR/stow/gui/nas/smb.conf
    sudo mkdir -p /etc/samba/

    # 检查目标文件是否存在，如果存在则删除
    # if [ -e /etc/samba/smb.conf ] || [ -L /etc/samba/smb.conf ]; then
    #     sudo rm /etc/samba/smb.conf
    # fi

    # sudo ln -s $ROOT_DIR/scripts/mesh/nas/smb.conf /etc/samba/smb.conf
    sudo smbpasswd -a tutu

    # 启动 SMB 文件共享服务
    sudo systemctl enable --now smb.service

    # 启动 NMB 网络浏览服务（可选，但推荐）
    sudo systemctl enable --now nmb.service


}

# 获取当前平台的 easytier 目录名（zip 解压后的子目录名）
get_easytier_platform_dir() {
    local arch="$(uname -m)"
    if is_macos; then
        echo "easytier-macos-aarch64"
    elif is_linux; then
        case "$arch" in
            x86_64)  echo "easytier-linux-x86_64" ;;
            aarch64) echo "easytier-linux-aarch64" ;;
            *)       echo "easytier-linux-${arch}" ;;
        esac
    fi
}

# 下载最新 easytier 二进制（x86_64 Linux + ARM macOS）
update_easytier() {
    # 已有最新版本则跳过
    if [ -f "$EASYTIER_DIR/version.txt" ]; then
        local current_version
        current_version=$(cat "$EASYTIER_DIR/version.txt")
        local platform_dir
        platform_dir=$(get_easytier_platform_dir)
        if [ -f "$EASYTIER_DIR/${platform_dir}/easytier-core" ]; then
            info "EasyTier ${current_version} 已存在，跳过下载"
            return 0
        fi
    fi

    local OWNER="EasyTier"
    local REPO="EasyTier"

    info "正在获取 EasyTier 最新版本号..."
    local LATEST_VERSION
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$LATEST_VERSION" ]; then
        error "无法获取 EasyTier 最新版本号"
        exit 1
    fi

    info "EasyTier 最新版本: ${LATEST_VERSION}"

    local BASE_URL="https://github.com/${OWNER}/${REPO}/releases/download/${LATEST_VERSION}"

    # x86_64 Linux + ARM macOS
    local PLATFORMS=("linux-x86_64" "macos-aarch64")
    local FILES=(
        "easytier-linux-x86_64-${LATEST_VERSION}.zip"
        "easytier-macos-aarch64-${LATEST_VERSION}.zip"
    )

    mkdir -p "$EASYTIER_DIR"
    cd "$EASYTIER_DIR"

    for i in "${!FILES[@]}"; do
        local FILE="${FILES[$i]}"
        local PLATFORM="${PLATFORMS[$i]}"
        local PLATFORM_DIR="easytier-${PLATFORM}"
        local DOWNLOAD_URL="${BASE_URL}/${FILE}"

        info "正在下载: ${FILE}"
        curl -fSL -o "./${FILE}" "${DOWNLOAD_URL}"

        info "正在解压: ${FILE}"
        rm -rf "./${PLATFORM_DIR}"
        unzip -o "./${FILE}"

        chmod +x "./${PLATFORM_DIR}/easytier-core" "./${PLATFORM_DIR}/easytier-cli" 2>/dev/null || true

        rm -f "./${FILE}"
    done

    echo "${LATEST_VERSION}" > "$EASYTIER_DIR/version.txt"

    success "EasyTier ${LATEST_VERSION} 下载完成"
}

# 链接二进制到 /usr/local/bin
install_easytier() {
    local platform_dir
    platform_dir=$(get_easytier_platform_dir)

    if [ ! -f "$EASYTIER_DIR/${platform_dir}/easytier-core" ]; then
        error "找不到二进制文件: $EASYTIER_DIR/${platform_dir}/easytier-core"
        info "请先运行更新下载二进制文件"
        return 1
    fi

    chmod +x "$EASYTIER_DIR/${platform_dir}/easytier-core"
    chmod +x "$EASYTIER_DIR/${platform_dir}/easytier-cli" 2>/dev/null || true

    local cmd="rm -f /usr/local/bin/easytier-core /usr/local/bin/easytier-cli && \
        ln -s $EASYTIER_DIR/${platform_dir}/easytier-core /usr/local/bin/easytier-core && \
        ln -s $EASYTIER_DIR/${platform_dir}/easytier-cli /usr/local/bin/easytier-cli"
    if which sudo &>/dev/null; then
        sudo sh -c "$cmd"
    else
        sh -c "$cmd"
    fi

    success "easytier-core 已安装到 /usr/local/bin/easytier-core"
}

# 配置 systemd/launchd 服务
install_easytier_service() {
    local platform_dir
    platform_dir=$(get_easytier_platform_dir)
    local config_dir="$EASYTIER_DIR/config"

    if [ ! -d "$config_dir" ] || [ -z "$(ls -A "$config_dir"/*.conf 2>/dev/null)" ]; then
        warning "没有找到配置文件 ($config_dir/*.conf)，跳过服务安装"
        return 0
    fi

    echo ""
    info "可用配置:"
    local configs=()
    for conf in "$config_dir"/*.conf; do
        local name
        name=$(basename "$conf" .conf)
        configs+=("$name")
        echo "  - $name ($conf)"
    done

    echo ""
    read -r -p "输入要启用的配置名 (多个用空格分隔): " SELECTED
    if [ -z "$SELECTED" ]; then
        warning "未选择配置，跳过服务安装"
        return 0
    fi

    if is_linux && command -v systemctl &>/dev/null; then
        # Linux: systemd 模板服务
        sudo tee /etc/systemd/system/easytier@.service > /dev/null << EOF
[Unit]
Description=EasyTier Service (%i)
Wants=network.target
After=network.target network.service
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=$EASYTIER_DIR/${platform_dir}/easytier-core -c $config_dir/%i.conf
Restart=always
RestartSec=3s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload

        for name in $SELECTED; do
            if [ -f "$config_dir/${name}.conf" ]; then
                sudo systemctl enable --now "easytier@${name}"
                success "easytier@${name} 服务已启用"
            else
                error "配置文件不存在: $config_dir/${name}.conf"
            fi
        done
    elif is_macos; then
        # macOS: 直接生成 launchd plist
        local easytier_bin
        easytier_bin=$(which easytier-core 2>/dev/null || echo "$EASYTIER_DIR/${platform_dir}/easytier-core")
        sudo mkdir -p /var/log/easytier
        for name in $SELECTED; do
            if [ -f "$config_dir/${name}.conf" ]; then
                local plist_name="com.easytier.${name}"
                sudo tee "/Library/LaunchDaemons/${plist_name}.plist" > /dev/null << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${plist_name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${easytier_bin}</string>
        <string>-c</string>
        <string>${config_dir}/${name}.conf</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/easytier/${name}.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/easytier/${name}.log</string>
</dict>
</plist>
PLIST
                sudo chown root:wheel "/Library/LaunchDaemons/${plist_name}.plist"
                sudo chmod 644 "/Library/LaunchDaemons/${plist_name}.plist"
                sudo launchctl load -w "/Library/LaunchDaemons/${plist_name}.plist"
                success "${plist_name} macOS 服务已安装"
            else
                error "配置文件不存在: $config_dir/${name}.conf"
            fi
        done
    else
        warning "不支持的平台，跳过服务安装"
    fi
}

read -r -p "reinstall smb? [y/N] " INSTALL_SMB
case "$INSTALL_SMB" in
    [yY])
        echo "开始安装..."
        install_SMB
esac

echo ""
read -r -p "update easytier binaries? [y/N] " UPDATE_EASYTIER
case "$UPDATE_EASYTIER" in
    [yY])
        update_easytier
        install_easytier
esac

echo ""
read -r -p "configure easytier service? [y/N] " CONFIG_EASYTIER
case "$CONFIG_EASYTIER" in
    [yY])
        install_easytier_service
esac
