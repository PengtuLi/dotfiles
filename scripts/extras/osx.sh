#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

register_keyboard_shortcuts() {
    # Register CTRL+/ keyboard shortcut to avoid system beep when pressed
    info "Registering keyboard shortcuts..."
    mkdir -p "$HOME/Library/KeyBindings"
    cat >"$HOME/Library/KeyBindings/DefaultKeyBinding.dict" <<EOF
EOF
}

enable_dev_tools_security() {
    sudo DevToolsSecurity --enable
}

enable_touch_id_for_sudo() {
    info "Enabling Touch ID for sudo..."
    # macOS Sonoma+ 提供 /etc/pam.d/sudo_local 供用户自定义，系统更新不会重置；
    # 直接改 /etc/pam.d/sudo 会在大版本更新后失效
    local pam_file="/etc/pam.d/sudo_local"
    local touch_id_line="auth sufficient pam_tid.so"

    if grep -q "$touch_id_line" "$pam_file" 2>/dev/null; then
        info "Touch ID already enabled for sudo"
        return
    fi

    printf '%s\n' "$touch_id_line" | sudo tee -a "$pam_file" >/dev/null
    info "Touch ID enabled for sudo"
}

apply_osx_system_defaults() {
    info "Applying OSX system defaults..."

    # Avoid creating .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # Show hidden files inside the finder
    defaults write com.apple.finder "AppleShowAllFiles" -bool true

    # Do not rearrange spaces automatically
    defaults write com.apple.dock "mru-spaces" -bool false

    # window arrange by app
    defaults write com.apple.dock expose-group-apps -bool true

    # Merge all displays into one Space (turn OFF "Displays have separate Spaces")
    defaults write com.apple.spaces spans-displays -bool true

    # Dock auto hide
    # defaults write com.apple.dock autohide -bool true

}

check_sleep_power_settings() {
    # 检测睡眠省电设置，未设置则提示用户开启（防止合盖后蓝牙频繁唤醒导致过夜掉电）
    info "Checking sleep power settings..."

    local remote_wake powernap tcpkeepalive
    remote_wake=$(defaults read /Library/Preferences/com.apple.Bluetooth RemoteWakeEnabled 2>/dev/null || echo 1)
    powernap=$(pmset -g custom | awk '/Battery Power/{f=1} /AC Power/{f=0} f && $1=="powernap"{print $2}')
    tcpkeepalive=$(pmset -g custom | awk '/Battery Power/{f=1} /AC Power/{f=0} f && $1=="tcpkeepalive"{print $2}')

    if [ "$remote_wake" != "0" ]; then
        warning "蓝牙唤醒未关闭（合盖后外设可能频繁唤醒电脑耗电），建议执行："
        warning "  sudo defaults write /Library/Preferences/com.apple.Bluetooth RemoteWakeEnabled -bool false"
    fi
    if [ "$powernap" != "0" ]; then
        warning "电池模式 Power Nap 未关闭（睡眠中定时唤醒同步），建议执行："
        warning "  sudo pmset -b powernap 0"
    fi
    if [ "$tcpkeepalive" != "0" ]; then
        warning "电池模式 TCP Keep Alive 未关闭（睡眠中保持联网，会影响查找我的 Mac），按需执行："
        warning "  sudo pmset -b tcpkeepalive 0"
    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    register_keyboard_shortcuts
    enable_dev_tools_security
    enable_touch_id_for_sudo
    apply_osx_system_defaults
    check_sleep_power_settings
fi

success "OSX 额外步骤完成"
