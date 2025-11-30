#!/usr/bin/env bash

set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

if [[ $# -lt 1 ]]; then
    error "Usage: $0 <preset>"
    exit 1
fi

PRESET="$1"

# 加载配置文件
CONFIG_FILE="$ROOT_DIR/scripts/config/presets.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi
source "$CONFIG_FILE"

if [[ ! -v BREW_BUNDLE_PRESET_COMPONENTS["$PRESET"] ]]; then
    error "未知的预设: $PRESET"
    error "有效预设: macos, linux-gui, linux-headless"
    exit 1
fi

IFS=' ' read -ra components <<< "${BREW_BUNDLE_PRESET_COMPONENTS[$PRESET]}"


if ! command -v brew &>/dev/null; then
    error "Homebrew 未安装或未在 PATH 中"
    exit 1
fi

BREWFILE=""
for component in "${components[@]}"; do
    BREWFILE=$component
done

# --- brew bundle install ---
info "install brew bundle"
BREWFILE="$ROOT_DIR/brewfile/$BREWFILE"
if [[ -f "$BREWFILE" ]]; then
    info "使用 ${BREWFILE} 安装 特定 软件包..."
    brew bundle --force --file "$BREWFILE"
else
    info "Brewfile ${BREWFILE} 不存在，跳过。"
fi
BREWFILE="$ROOT_DIR/brewfile/Brewfile"
info "使用 ${BREWFILE} 安装 特定 软件包..."
brew bundle --force --file "$BREWFILE"

# 若文件不存在则先创建
[[ -f "$ZSHRC" ]] || touch "$ZSHRC"
