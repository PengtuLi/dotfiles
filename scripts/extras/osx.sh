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

sudo DevToolsSecurity --enable

enable_touch_id_for_sudo() {
    info "Enabling Touch ID for sudo..."
    local pam_file="/etc/pam.d/sudo"
    local touch_id_line="auth sufficient pam_tid.so"

    if grep -q "$touch_id_line" "$pam_file" 2>/dev/null; then
        info "Touch ID already enabled for sudo"
        return
    fi

    # Backup and modify PAM config
    sudo cp "$pam_file" "${pam_file}.bak"
    sudo sed -i '' "1s/^/$touch_id_line\n/" "$pam_file"
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

    # Displays have separate Spaces
    defaults write com.apple.spaces spans-displays -bool true

    # Dock auto hide
    # defaults write com.apple.dock autohide -bool true

}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    register_keyboard_shortcuts
    enable_touch_id_for_sudo
    apply_osx_system_defaults
fi

success "OSX 额外步骤完成"
