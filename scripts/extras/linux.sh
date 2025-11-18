#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

install_niri() {

    if ! command -v yay &>/dev/null; then
        warning "未找到 yay，正在尝试安装 yay..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    fi

    local packages=(
        # niri                 # windows manager
        # xwayland-satellite
        # waybar               # status bar
        # fuzzel               # launch pad
        # gdm                  # display manager
        # swaync                  # Notification Daemon
        # // portal
        # xdg-desktop-portal-gtk # Portals#
        # xdg-desktop-portal-gnome # Portals#
        # gnome-keyring
        # // Authentication Agent
        # plasma-polkit-agent

        # swww             # 设置壁纸
        # hyprlock            # lock screen
        # nautilus            # file manager
        # dolphin              # file manager kde
        # swayidle           # 休眠管理
        # brightnessctl        # 亮度管理
        # wlr-randr            # 多屏幕显示器方向, not need anymore

        # // audio
        # pipewire
        # pipewire-pulse
        # pipewire-alsa
        # wireplumber
        # sof-firmware
        # pavucontrol         # gui mgr

        # // blurtooth
        # bluez
        # blueman
        # timeshift           # snapshot tool
        # grub-btrfs
        #


        # vlc                               # media player
        # google-chrome
        # wechat-bin
        # wps-office-cn
        # tencent-meeting
        # ghostty                           # GPU 加速终端
        # Visual-Studio-Code-bin
        # spotify

        # font
        # adobe-source-han-sans-cn-fonts
        # adobe-source-han-serif-cn-fonts


        # input
        # fcit5-im
        # fcitx5-chinese-addons
        # fcitx5-material-color
        # fcitx5-qt
        # fcitx5-gtk

    )

    for pkg in "${packages[@]}"; do
        echo ">>> 正在安装 $pkg ..."
        if pacman -Si "$pkg" &> /dev/null; then
            if ! sudo pacman -S --noconfirm "$pkg"; then
                error "pacman 安装 $pkg 失败"
                exit 1
            fi
        else
            if ! yay -S --noconfirm "$pkg"; then
                error "yay 安装 $pkg 失败"
                exit 1
            fi
        fi
        success "✓ $pkg 安装成功"
    done

    sudo tee ~/.config/systemd/user/swww.service > /dev/null << 'EOF'
[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=swww-daemon
Restart=on-failure
EOF

    sudo tee ~/.config/systemd/user/swayidle.service > /dev/null << 'EOF'
[Unit]
PartOf=graphical-session.target
After=graphical-session.target
Requisite=graphical-session.target

[Service]
ExecStart=/usr/bin/swayidle -w timeout 1800 'niri msg action power-off-monitors' timeout 3600 'hyprlock' before-sleep 'hyprlock'
Restart=on-failure
EOF

    systemctl --user add-wants niri.service swaync.service
    systemctl --user add-wants niri.service waybar.service
    systemctl --user add-wants niri.service swww.service
    systemctl --user add-wants niri.service swayidle.service

    systemctl --user daemon-reload



}

install_wifi(){
    #!/bin/bash
    SSID="SYSU-SECURE"
    NETID=""
    PASSWORD=""
    DEVICE="wlp6s0"
    CONFIG="/etc/NetworkManager/system-connections/${SSID}.nmconnection"

    sudo tee $CONFIG > /dev/null << EOF
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


if is_arch_linux; then
    echo ""
    read -r -p "检测到 Arch Linux，是否安装 niri 桌面环境？[y/N]: " proceed
    case "$proceed" in
        [yY])
            echo "开始安装..."
            install_niri
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
