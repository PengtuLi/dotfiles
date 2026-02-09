#!/bin/bash

# Get the absolute path of the directory where the script is located
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

ZSHRC_FILE="$HOME/.zshrc"
DOTFILES_ZSHRC="$ROOT_DIR/shell/zsh/.zshrc"

# Add source line to ~/.zshrc if not already present
add_zshrc_source() {
    local line="source \"$DOTFILES_ZSHRC\""

    if ! grep -qF -- "$line" "$ZSHRC_FILE" 2>/dev/null; then
        info "Adding dotfiles zshrc to $ZSHRC_FILE..."
        # Backup first
        cp "$ZSHRC_FILE" "${ZSHRC_FILE}.bak" 2>/dev/null || true
        echo "" >> "$ZSHRC_FILE"
        echo "# Dotfiles zshrc" >> "$ZSHRC_FILE"
        echo "$line" >> "$ZSHRC_FILE"
        success "Done. Restart your terminal or run 'source $ZSHRC_FILE'"
    else
        warning "Dotfiles zshrc already sourced in $ZSHRC_FILE"
    fi
}

# Setup local bin symlinks
setup_local_bin() {
    local bin_src="$ROOT_DIR/.local/bin"
    local bin_dest="$HOME/.local/bin"

    if [ ! -d "$bin_dest" ]; then
        mkdir -p "$bin_dest"
    fi

    info "Setting up local bin symlinks..."

    # Make all scripts executable
    find "$bin_src" -type f -exec chmod +x {} \;

    # Create symlinks (excluding lib/ directory)
    for file in "$bin_src"/*; do
        if [ -f "$file" ]; then
            local basename=$(basename "$file")
            ln -sf "$file" "$bin_dest/$basename"
        fi
    done

    success "Bin scripts installed"
}

# Main
add_zshrc_source
setup_local_bin
