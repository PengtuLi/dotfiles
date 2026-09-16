#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

update_system() {
    info "刷新包数据库..."
    sudo pacman -Sy
    UPDATE_INSTALLED=1
    success "将更新列表中已安装的包"
}

install_niri() {

    if ! command -v yay &>/dev/null; then
        warning "未找到 yay，正在尝试安装 yay..."
        local tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        cd "$tmpdir/yay"
        makepkg -si --noconfirm
        cd "$ROOT_DIR"
    fi

    confirm_run "是否更新列表中已安装的包（默认跳过，不做全系统 Syu）？" update_system

    local packages=(
        niri                    # window manager
        xwayland-satellite
        waybar                  # status bar
        fuzzel                  # launcher
        gdm                     # display manager
        swaync                  # notification daemon
        xdg-desktop-portal-gnome # with gdm
        xdg-desktop-portal-gtk
        gnome-keyring
        polkit-gnome

        awww                    # 壁纸
        hyprlock                # 锁屏
        nautilus                # 文件管理器
        swayidle                # 休眠管理
        brightnessctl           # 亮度管理

        pipewire
        pipewire-pulse
        pipewire-alsa
        wireplumber
        sof-firmware
        pavucontrol

        # 蓝牙
        bluez
        blueman
        # 快照
        timeshift
        grub-btrfs

        vlc
        google-chrome
        wechat-bin
        wps-office-cn
        ghostty-nightly-bin     # GPU 加速终端
        visual-studio-code-bin

        # 输入法
        fcitx5-im               # meta: fcitx5 + gtk/qt/configtool
        fcitx5-chinese-addons   # 拼音、注音等
        fcitx5-material-color   # 主题

        # 字体
        adobe-source-han-sans-cn-fonts
        adobe-source-han-serif-cn-fonts
    )

    for pkg in "${packages[@]}"; do
        if pacman -Qq "$pkg" &>/dev/null && [[ "${UPDATE_INSTALLED:-0}" != "1" ]]; then
            info "$pkg 已安装，跳过"
            continue
        fi
        echo ">>> 正在安装 $pkg ..."
        if pacman -Si "$pkg" &> /dev/null; then
            if ! sudo pacman -S --needed --noconfirm "$pkg"; then
                error "pacman 安装 $pkg 失败"
                exit 1
            fi
        else
            if ! output=$(yay -S --needed --noconfirm "$pkg" 2>&1); then
                error "yay 安装 $pkg 失败"
                echo "$output"
                exit 1
            fi
        fi
        success "✓ $pkg 安装成功"
    done

    mkdir -p ~/.config/systemd/user
    tee ~/.config/systemd/user/awww.service > /dev/null << 'EOF'
[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=awww-daemon
Restart=on-failure
EOF

    tee ~/.config/systemd/user/swayidle.service > /dev/null << 'EOF'
[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w timeout 1800 'hyprlock & sleep 1 && niri msg action power-off-monitors' resume 'niri msg action power-on-monitors' before-sleep 'hyprlock'
Restart=on-failure
EOF

    systemctl --user add-wants niri.service swaync.service
    systemctl --user add-wants niri.service waybar.service
    systemctl --user add-wants niri.service awww.service
    systemctl --user add-wants niri.service swayidle.service

    systemctl --user daemon-reload



}

install_fontconfig() {
    sudo tee /etc/fonts/local.conf > /dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Source Han Sans CN</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Source Han Serif CN</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Maple Mono NF CN</family>
    </prefer>
  </alias>
</fontconfig>
EOF

    fc-cache -fv
    success "字体配置完成"
    echo "  sans-serif → $(fc-match sans-serif)"
    echo "  serif      → $(fc-match serif)"
    echo "  monospace  → $(fc-match monospace)"
}

install_wifi(){
    SSID="SYSU-SECURE"
    NETID=""
    PASSWORD=""
    DEVICE="wlp6s0"
    CONFIG="/etc/NetworkManager/system-connections/${SSID}.nmconnection"

    sudo tee "$CONFIG" > /dev/null << EOF
[connection]
id=$SSID
type=wifi
# interface-name=$DEVICE
autoconnect=true

[wifi]
mode=infrastructure
ssid=$SSID
mac-address-randomization=1

[wifi-security]
key-mgmt=wpa-eap

[802-1x]
eap=peap
identity=$NETID
password=$PASSWORD
phase2-auth=mschapv2
ca-cert=
system-ca-certs=false

[ipv4]
method=auto

[ipv6]
method=auto
EOF

    sudo chmod 600 "$CONFIG"
    sudo chown root:root "$CONFIG"
    sudo systemctl restart NetworkManager
    echo "已配置 $SSID"
}

install_rclone(){

    cat > ~/.config/systemd/user/rclone-gdrive.service <<EOF
[Unit]
Description=Rclone Google Drive Mount
After=network-online.target

[Service]
Type=notify
ExecStart=$(which rclone) mount gdive-316pc: $HOME/workspace/gdrive \
  --vfs-cache-mode writes \
  --dir-cache-time 72h \
  --log-level INFO \
  --log-file /tmp/rclone-gdrive.log
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable rclone-gdrive.service
    systemctl --user start rclone-gdrive.service
}


troubleshoot_tips() {
    info "========== Arch Linux 常見問題排查 =========="
    echo ""
    echo "1. CMake: 'Package xxx not found' 但 pacman 顯示已安裝"
    echo "   → linuxbrew 的 pkg-config 覆盖了系统版本，搜索路径不含 /usr/lib/pkgconfig"
    echo "   → 修复：~/.zshrc 中 brew shellenv 之后加："
    echo '     export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH:}/usr/lib/pkgconfig:/usr/share/pkgconfig"'
    echo ""
    echo "2. yay: 'request failed: Get ... EOF'"
    echo "   → AUR API 连接失败，校园网 DNS 被污染"
    echo "   → 修复：mihomo nameserver 加 #proxy；或加 /etc/hosts 条目"
    echo ""
    success "排查提示输出完毕"
    echo ""
}


confirm_run() {
    local prompt="$1" func="$2"
    read -r -p "$prompt [y/N]: " proceed
    case "$proceed" in
        [yY])
            echo "开始执行..."
            "$func"
            ;;
    esac
}

if is_arch_linux; then
    echo ""
    confirm_run "检测到 Arch Linux，是否运行常见问题排查？" troubleshoot_tips
    confirm_run "检测到 Arch Linux，是否安装 niri 桌面环境？" install_niri
    confirm_run "检测到 Arch Linux，是否配置字体？" install_fontconfig
    confirm_run "检测到 Arch Linux，是否配置 wifi？" install_wifi
    confirm_run "检测到 Arch Linux，是否配置 rclone？" install_rclone
fi


success "Linux 额外步骤完成"
