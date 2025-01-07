#!/bin/zsh

# Stow 相关辅助函数，需要先 source scripts/lib/common.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$ROOT_DIR/scripts/lib/common.sh"

set -euo pipefail

stow_packages() {
  local dir="$1"
  [[ -d "$dir" ]] || return
  pushd "$dir" >/dev/null
  for pkg in *; do
    case "$pkg" in linux|osx|macos) continue ;; esac
    [[ -d "$pkg" ]] || continue

    IFSUDO="" # FIX: remove osx related
    if [[ "$pkg" =~ ^(vscode)$ ]] && is_macos; then
      target="$HOME/Library/Application Support"
    elif [[ "$pkg" =~ ^(vscode)$ ]] && is_linux; then
      target="$HOME/.config"
    elif [[ "$pkg" =~ ^(nginx)$ ]]; then
      target="/opt/homebrew/etc"
    else
      target="$HOME"
    fi

    info "--Stowing $pkg (from $dir) to target $target"
    if [ -e "$target/$pkg" ]; then
    # 存在但不是软链接（普通文件/目录），直接删除
      $IFSUDO rm -rf "$target/$pkg" && $IFSUDO stow --restow -v --target="$target" "$pkg"
    else
      $IFSUDO stow --restow -v --target="$target" "$pkg"
    fi
  done
  popd >/dev/null
}
