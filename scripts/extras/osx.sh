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
{
 "^\U002F" = "noop";
}
EOF
}

sudo DevToolsSecurity --enable

apply_osx_system_defaults() {
    info "Applying OSX system defaults..."

    # Avoid creating .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # Show hidden files inside the finder
    defaults write com.apple.finder "AppleShowAllFiles" -bool true

    # Do not rearrange spaces automatically
    defaults write com.apple.dock "mru-spaces" -bool false

}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    register_keyboard_shortcuts
    apply_osx_system_defaults
fi

success "OSX 额外步骤完成"
