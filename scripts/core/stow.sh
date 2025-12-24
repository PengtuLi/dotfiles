#!/usr/bin/env bash

set -euo pipefail

PLATFORM="$1"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
source "$ROOT_DIR/scripts/lib/stow_helpers.sh"

if ! command -v stow &>/dev/null; then
    error "GNU Stow 未安装（请确保 Brewfile 中包含 stow ）"
    exit 1
fi

STOW_CLI_DIR="$ROOT_DIR/stow/cli"
info "stow $STOW_CLI_DIR"
stow_packages "$STOW_CLI_DIR"

if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] || [ "$(uname)" = "Darwin" ]; then
    GUI_DIR="$ROOT_DIR/stow/gui"
    info "stow $GUI_DIR"
    stow_packages "$GUI_DIR"
fi

success "符号链接创建完成 (${PLATFORM})"
