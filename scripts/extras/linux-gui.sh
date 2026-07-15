#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

install_niri() {

    if ! command -v yay &>/dev/null; then
        warning "未找到 yay，正在尝试安装 yay..."
        local tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
        cd "$tmpdir/yay"
        makepkg -si --noconfirm
        cd "$ROOT_DIR"
    fi

    local packages=(
        # niri                 # windows manager
        # xwayland-satellite
        # waybar               # status bar
        # fuzzel               # launch pad
        # gdm                  # display manager
        # swaync                  # Notification Daemon
        # xdg-desktop-portal-gnome # with gdm
        # xdg-desktop-portal-gtk
        # gnome-keyring
        # polkit-gnome

        # awww             # 设置壁纸
        # hyprlock            # lock screen
        # nautilus            # file manager
        # swayidle           # 休眠管理
        # brightnessctl        # 亮度管理

        # pipewire
        # pipewire-pulse
        # pipewire-alsa
        # wireplumber
        # sof-firmware
        # pavucontrol

        # # 藍牙
        # bluez
        # blueman
        # # 快照
        # timeshift
        # grub-btrfs

        # vlc
        # google-chrome
        # wechat-bin
        # wps-office-cn
        # ghostty                           # GPU 加速终端
        # visual-studio-code-bin

        # input
        # fcitx5-im                # meta: fcitx5 + gtk/qt/configtool
        # fcitx5-chinese-addons    # 拼音、注音等
        # fcitx5-material-color    # 主題

        # fonts
        # adobe-source-han-sans-cn-fonts
        # adobe-source-han-serif-cn-fonts

    )

    for pkg in "${packages[@]}"; do
        echo ">>> 正在安装 $pkg ..."
        if pacman -Si "$pkg" &> /dev/null; then
            if ! sudo pacman -S --noconfirm "$pkg"; then
                error "pacman 安装 $pkg 失败"
                exit 1
            fi
        else
            output=$(yay -S --noconfirm "$pkg" 2>&1) || true
            if echo "$output" | grep -qi "there is nothing to do\|no aur package found\|failed"; then
                error "yay 安装 $pkg 失败"
                echo "$output"
                exit 1
            fi
        fi
        success "✓ $pkg 安装成功"
    done

    mkdir -p ~/.config/systemd/user
    sudo tee ~/.config/systemd/user/awww.service > /dev/null << 'EOF'
[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=awww-daemon
Restart=on-failure
EOF

    sudo tee ~/.config/systemd/user/swayidle.service > /dev/null << 'EOF'
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
    success "字體配置完成"
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
    echo "   → linuxbrew 的 pkg-config 覆蓋了系統版本，搜索路徑不含 /usr/lib/pkgconfig"
    echo "   → 修復：~/.zshrc 中 brew shellenv 之後加："
    echo '     export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:+$PKG_CONFIG_PATH:}/usr/lib/pkgconfig:/usr/share/pkgconfig"'
    echo ""
    echo "2. yay: 'request failed: Get ... EOF'"
    echo "   → AUR API 連接失敗，校園網 DNS 被汙染"
    echo "   → 修復：mihomo nameserver 加 #proxy；或加 /etc/hosts 條目"
    echo ""
    success "排查提示輸出完畢"
    echo ""
}


if is_arch_linux; then
    echo ""
    read -r -p "检测到 Arch Linux，是否运行常见问题排查？[y/N]: " proceed
    case "$proceed" in
        [yY])
            troubleshoot_tips
    esac
    read -r -p "检测到 Arch Linux，是否安装 niri 桌面环境？[y/N]: " proceed
    case "$proceed" in
        [yY])
            echo "开始安装..."
            install_niri
    esac
    read -r -p "检测到 Arch Linux，是否配置字体？[y/N]: " proceed
    case "$proceed" in
        [yY])
            install_fontconfig
    esac
    read -r -p "检测到 Arch Linux，是否安装 wifi [y/N]: " proceed
    case "$proceed" in
        [yY])
            echo "开始安装..."
            install_wifi
    esac
    read -r -p "检测到 Arch Linux，是否安装 rclone [y/N]: " proceed
    case "$proceed" in
        [yY])
            echo "开始安装..."
            install_rclone
    esac
fi


success "Linux 额外步骤完成"
