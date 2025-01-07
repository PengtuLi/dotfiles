#!/bin/bash

# Get the absolute path of the directory where the script is located
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

add_scripts() {
    local ZSHRC_FILE="$HOME/.zshrc"
    # The lines you want to add
    LINE_TO_ADD=$(cat << EOF
# shell scripts
chmod +x "$ROOT_DIR/shell/zsh/zsh_unplugged.zsh"
source "$ROOT_DIR/shell/zsh/zsh_unplugged.zsh"
chmod +x "$ROOT_DIR/shell/zsh/.zshrc"
source "$ROOT_DIR/shell/zsh/.zshrc"
chmod +x "$ROOT_DIR/shell/bash/alias.sh"
source "$ROOT_DIR/shell/bash/alias.sh"
chmod +x "$ROOT_DIR/shell/bash/util.sh"
source "$ROOT_DIR/shell/bash/util.sh"
EOF
    )

    # Check if the lines already exist in .zshrc
    if ! grep -qF -- "$LINE_TO_ADD" "$ZSHRC_FILE"; then
        info "Adding scripts loading to $ZSHRC_FILE..."
        append_to_zshrc_if_missing "$LINE_TO_ADD"
        info "Done. Please restart your terminal or run 'source $ZSHRC_FILE' for changes to take effect."
    else
        warning "scripts loading lines already exist in $ZSHRC_FILE. No changes made."
    fi
}

# Call the function to execute the logic
add_scripts
