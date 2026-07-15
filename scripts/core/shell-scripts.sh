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

# Change default shell to zsh (asks user first, skips if already zsh)
change_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh 2>/dev/null)"

    if [ -z "$zsh_path" ]; then
        warning "zsh not found, skipping default shell change"
        return
    fi

    if [ "$SHELL" = "$zsh_path" ]; then
        warning "Default shell is already zsh ($zsh_path), skipping"
        return
    fi

    read -r -p "Change default shell to zsh ($zsh_path)? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        info "Changing default shell to $zsh_path..."
        # Ensure zsh is in /etc/shells
        if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        chsh -s "$zsh_path"
        success "Default shell changed to zsh (takes effect on next login)"
    else
        info "Skipped changing default shell"
    fi
}

# Generate en_US.UTF-8 and zh_CN.UTF-8 locales (skips if already generated)
# Works on both Debian/Ubuntu and Arch-based systems (same /etc/locale.gen + locale-gen flow)
setup_locales() {
    if ! command -v locale-gen >/dev/null 2>&1; then
        warning "locale-gen not found, skipping locale setup"
        return
    fi

    local need_gen=0
    for locale in en_US.UTF-8 zh_CN.UTF-8; do
        # locale -a normalizes to form like "en_US.utf8"
        if locale -a 2>/dev/null | grep -qi "${locale%%.*}\.utf8$\|${locale%%.*}\.UTF-8$"; then
            continue
        fi
        need_gen=1
    done

    if [ "$need_gen" -eq 0 ]; then
        warning "Locales en_US.UTF-8 and zh_CN.UTF-8 already generated, skipping"
        return
    fi

    info "Generating UTF-8 locales..."
    sudo touch /etc/locale.gen
    sudo sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
    sudo sed -i 's/^# *zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
    sudo locale-gen
    success "Locales generated"
}

# Main
change_default_shell
setup_locales
add_zshrc_source
setup_local_bin
