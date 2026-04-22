#!/bin/bash
set -euo pipefail

# Get the dotfiles root directory using git
ROOT_DIR="$(git -C "$(dirname "${BASH_SOURCE[0]}")/.." rev-parse --show-toplevel)"

# Check if sops is installed
if ! command -v sops &> /dev/null; then
    echo "⚠️  sops command could not be found. Please install sops."
    exit 1
fi

# Decrypt function with error handling
decrypt_if_needed() {
    local source_file="$1"
    local target_file="$2"
    local chmod_perms="${3:-}"

    # Skip if source file doesn't exist
    if [ ! -f "$source_file" ]; then
        echo "  Source file not found: $source_file"
        return 1
    fi

    if [ -f "$target_file" ]; then
        local temp_decrypted
        temp_decrypted=$(mktemp)

        if ! sops decrypt --input-type=binary --output-type=binary "$source_file" > "$temp_decrypted" 2>/dev/null; then
            echo "  Failed to decrypt: $source_file" >&2
            rm -f "$temp_decrypted"
            return 1
        fi

        if cmp -s "$target_file" "$temp_decrypted"; then
            echo "'$target_file' exists and content is identical. Skipping."
            rm -f "$temp_decrypted"
        else
            echo "  '$target_file' exists and differs from decrypted content."
            echo "Skipping decryption to prevent overwriting your changes."
            rm -f "$temp_decrypted"
        fi
    else
        echo "Decrypting '$source_file' to '$target_file'"
        if ! sops decrypt --input-type=binary --output-type=binary "$source_file" > "$target_file" 2>/dev/null; then
            echo "  Failed to decrypt: $source_file" >&2
            return 1
        fi
    fi

    # Apply permissions if specified
    if [ -n "$chmod_perms" ] && [ -f "$target_file" ]; then
        chmod "$chmod_perms" "$target_file"
    fi
}

decrypt_if_needed "$ROOT_DIR/stow/cli/ssh/.ssh/id_rsa.sops" "$ROOT_DIR/stow/cli/ssh/.ssh/id_rsa" "600"
decrypt_if_needed "$ROOT_DIR/stow/cli/ssh/.ssh/config.sops" "$ROOT_DIR/stow/cli/ssh/.ssh/config" ""
decrypt_if_needed "$ROOT_DIR/mihomo-clash/config/config.yaml.sops" "$ROOT_DIR/mihomo-clash/config/config.yaml" ""
decrypt_if_needed "$ROOT_DIR/stow/cli/gh/.config/gh/hosts.yml.sops" "$ROOT_DIR/stow/cli/gh/.config/gh/hosts.yml" "600"
decrypt_if_needed "$ROOT_DIR/shell/.env.secrets.sops" "$ROOT_DIR/shell/.env.secrets" "600"
decrypt_if_needed "$ROOT_DIR/stow/cli/claude-code/.claude/settings.json.sops" "$ROOT_DIR/stow/cli/claude-code/.claude/settings.json" ""
decrypt_if_needed "$ROOT_DIR/stow/cli/opencode/.config/opencode/opencode.json.sops" "$ROOT_DIR/stow/cli/opencode/.config/opencode/opencode.json" ""

echo "Secrets decryption process finished."
