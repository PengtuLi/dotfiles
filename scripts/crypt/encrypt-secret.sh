#!/bin/bash
# 确保在脚本出错时立即退出
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# 检查 sops 命令是否存在
if ! command -v sops &> /dev/null
then
    echo "⚠️  sops command could not be found. Please install sops."
    exit 1
fi

SSH_KEY_SOURCE="stow/common/ssh/.ssh/id_rsa"
SSH_KEY_SOPS="stow/common/ssh/.ssh/id_rsa.sops"
SSH_CONFIG="stow/common/ssh/.ssh/config"
SSH_CONFIG_SOPS="stow/common/ssh/.ssh/config.sops"
CLASH_CONFIG_SOURCE="$ROOT_DIR/mihomo-clash/config/config.yaml"
CLASH_CONFIG_SOPS="$ROOT_DIR/mihomo-clash/config/config.yaml.sops"

# --- 加密逻辑 ---

echo "Running pre-commit hook to encrypt secrets..."

# 加密文件函数
encrypt_if_changed() {
    local source_file="$1"
    local encrypted_file="$2"
    local description="$3"
    local add_force="$4"  # "force" 表示使用 git add -f

    if [ ! -f "$source_file" ]; then
        echo "   -> Source $description not found."
        return
    fi

    echo "   -> Processing $description..."

    # 获取源文件的校验和
    local current_checksum
    if command -v sha256sum >/dev/null 2>&1; then
        current_checksum=$(sha256sum "$source_file" | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        current_checksum=$(shasum -a 256 "$source_file" | cut -d' ' -f1)
    else
        # fallback to md5 if sha256 is not available
        current_checksum=$(md5sum "$source_file" | cut -d' ' -f1)
    fi

    local checksum_file="${encrypted_file}.checksum"

    # 检查校验和文件是否存在，以及源文件是否发生了变化
    if [ -f "$checksum_file" ] && [ -f "$encrypted_file" ]; then
        local stored_checksum=$(cat "$checksum_file")
        if [ "$stored_checksum" = "$current_checksum" ]; then
            echo "      $description unchanged, skipping encryption"
        else
            # 源文件已修改，重新加密
            sops encrypt --input-type=binary --output-type=binary "$source_file" > "$encrypted_file"
            echo "$current_checksum" > "$checksum_file"
            if [ "$add_force" = "force" ]; then
                git add -f "$encrypted_file" "$checksum_file"
            else
                git add "$encrypted_file" "$checksum_file"
            fi
            echo "      Encrypted and staged: $encrypted_file"
        fi
    else
        # 第一次加密或加密文件不存在
        sops encrypt --input-type=binary --output-type=binary "$source_file" > "$encrypted_file"
        echo "$current_checksum" > "$checksum_file"
        if [ "$add_force" = "force" ]; then
            git add -f "$encrypted_file" "$checksum_file"
        else
            git add "$encrypted_file" "$checksum_file"
        fi
        echo "      Encrypted and staged: $encrypted_file"
    fi
}

# 1. 加密 SSH 私钥
encrypt_if_changed "$SSH_KEY_SOURCE" "$SSH_KEY_SOPS" "SSH key" "normal"
encrypt_if_changed "$SSH_CONFIG" "$SSH_CONFIG_SOPS" "SSH config" "normal"

# 2. 加密 Clash 配置文件
encrypt_if_changed "$CLASH_CONFIG_SOURCE" "$CLASH_CONFIG_SOPS" "Clash config" "force"

echo "Pre-commit encryption hook finished."
