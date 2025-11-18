#!/bin/bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if ! command -v sops &> /dev/null
then
    echo "⚠️  sops command could not be found. Please install sops."
    exit 1
fi

decrypt_if_needed() {
    local source_file=$1
    local target_file=$2
    local chmod_perms=$3

    # 根据文件扩展名确定文件类型
    local input_type="binary"  # 默认为 binary
    # if [[ "$source_file" == *.yaml.sops ]] || [[ "$source_file" == *.yml.sops ]]; then
    #     input_type="yaml"
    # elif [[ "$source_file" == *.json.sops ]]; then
    #     input_type="json"
    # elif [[ "$source_file" == *.env.sops ]]; then
    #     input_type="dotenv"
    # elif [[ "$source_file" == *.ini.sops ]]; then
    #     input_type="ini"
    # fi

    if [ -f "$target_file" ]; then
        local temp_decrypted=$(mktemp)

        # 使用正确的参数名称：--input-type 和 --output-type
        sops decrypt --input-type="$input_type" --output-type="$input_type" "$source_file" > "$temp_decrypted"

        if cmp -s "$target_file" "$temp_decrypted"; then
            echo "'$target_file' exists and content is identical. Skipping."
            rm "$temp_decrypted"
        else
            echo "⚠️: '$target_file' exists and differs from decrypted content."
            echo "Skipping decryption to prevent overwriting your changes."
            rm "$temp_decrypted"
        fi
    else
        # 使用正确的参数名称：--input-type 和 --output-type
        echo "Decrypting '$source_file' to '$target_file' (type: $input_type)"
        sops decrypt --input-type="$input_type" --output-type="$input_type" "$source_file" > "$target_file"
    fi

    if [ ! -z "${chmod_perms:-}" ] && [ -f "$target_file" ]; then
        chmod "$chmod_perms" "$target_file"
    fi
}

SSH_KEY="$ROOT_DIR/stow/cli/ssh/.ssh/id_rsa"
SSH_KEY_SOPS=$SSH_KEY.sops
SSH_CONFIG="$ROOT_DIR/stow/cli/ssh/.ssh/config"
SSH_CONFIG_SOPS=$SSH_CONFIG.sops
CLASH_CONFIG="$ROOT_DIR/mihomo-clash/config/config.yaml"
CLASH_CONFIG_SOPS=$CLASH_CONFIG.sops
GH_HOST="$ROOT_DIR/stow/cli/gh/.config/gh/hosts.yml"
GH_HOST_SOPS=$GH_HOST.sops

decrypt_if_needed "$SSH_KEY_SOPS" "$SSH_KEY" "600"
decrypt_if_needed "$SSH_CONFIG_SOPS" "$SSH_CONFIG" ""
decrypt_if_needed "$CLASH_CONFIG_SOPS" "$CLASH_CONFIG" ""
decrypt_if_needed "$GH_HOST_SOPS" "$GH_HOST" "600"

echo "🔐 Secrets decryption process finished."
