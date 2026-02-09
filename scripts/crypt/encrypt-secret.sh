#!/bin/bash
# 确保在脚本出错时立即退出
set -euo pipefail

# Get the dotfiles root directory using git
ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")/.." rev-parse --show-toplevel)"

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "⚠️  sops command could not be found. Please install sops."
    exit 1
fi

# Encrypt function with checksum comparison
encrypt_if_changed() {
    local source_file="$1"
    local encrypted_file="$2"
    local description="$3"
    local add_force="${4:-normal}"  # "force" 表示使用 git add -f

    if [ ! -f "$source_file" ]; then
        echo "   -> Source $description not found."
        return 0
    fi

    echo "   -> Processing $description..."

    # Get source file checksum
    local current_checksum
    if command -v sha256sum &>/dev/null; then
        current_checksum=$(sha256sum "$source_file" | cut -d' ' -f1)
    elif command -v shasum &>/dev/null; then
        current_checksum=$(shasum -a 256 "$source_file" | cut -d' ' -f1)
    else
        current_checksum=$(md5sum "$source_file" | cut -d' ' -f1)
    fi

    local checksum_file="${encrypted_file}.checksum"

    # Check if re-encryption is needed
    if [ -f "$checksum_file" ] && [ -f "$encrypted_file" ]; then
        local stored_checksum
        stored_checksum=$(cat "$checksum_file")
        if [ "$stored_checksum" = "$current_checksum" ]; then
            echo "      $description unchanged, skipping encryption"
            return 0
        fi
    fi

    # Encrypt the file
    if ! sops encrypt --input-type=binary --output-type=binary "$source_file" > "$encrypted_file" 2>/dev/null; then
        echo "      ❌ Failed to encrypt: $source_file" >&2
        return 1
    fi

    # Save checksum and stage files
    echo "$current_checksum" > "$checksum_file"

    if [ "$add_force" = "force" ]; then
        git add -f "$encrypted_file" "$checksum_file"
    else
        git add "$encrypted_file" "$checksum_file"
    fi
    echo "      Encrypted and staged: $encrypted_file"
}

echo "Running pre-commit hook to encrypt secrets..."

# Secret files configuration
encrypt_if_changed "$ROOT_DIR/stow/cli/ssh/.ssh/id_rsa" "$ROOT_DIR/stow/cli/ssh/.ssh/id_rsa.sops" "SSH key" "normal"
encrypt_if_changed "$ROOT_DIR/stow/cli/ssh/.ssh/config" "$ROOT_DIR/stow/cli/ssh/.ssh/config.sops" "SSH config" "normal"
encrypt_if_changed "$ROOT_DIR/mihomo-clash/config/config.yaml" "$ROOT_DIR/mihomo-clash/config/config.yaml.sops" "Clash config" "force"
encrypt_if_changed "$ROOT_DIR/stow/cli/gh/.config/gh/hosts.yml" "$ROOT_DIR/stow/cli/gh/.config/gh/hosts.yml.sops" "gh auth" "normal"
encrypt_if_changed "$ROOT_DIR/shell/.env.secrets" "$ROOT_DIR/shell/.env.secrets.sops" "env secrets" "normal"

echo "Pre-commit encryption hook finished."
