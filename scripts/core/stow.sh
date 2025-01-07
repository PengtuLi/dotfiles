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

STOW_COMMON_DIR="$ROOT_DIR/stow/common"
info "stow $STOW_COMMON_DIR"
stow_packages "$STOW_COMMON_DIR"

if [[ "$PLATFORM" == linux ]] ; then
    LINUX_DIR="$ROOT_DIR/stow/linux"
    info "stow $LINUX_DIR"
    stow_packages "$LINUX_DIR"
elif [[ "$PLATFORM" == osx ]] ; then
    OSX_DIR="$ROOT_DIR/stow/osx"
    info "stow $OSX_DIR"
    stow_packages "$OSX_DIR"
fi

info "stow shell/zsh"
stow_packages "$ROOT_DIR/shell/zsh/"

success "符号链接创建完成 (${PLATFORM})"
