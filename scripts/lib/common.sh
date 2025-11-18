#!/usr/bin/env bash

# 通用函数与颜色工具
# --------------

set -euo pipefail

# 颜色定义（若终端不支持 tput 将静默失败）
default_color=$(tput sgr 0 2>/dev/null || echo "")
red=$(tput setaf 1 2>/dev/null || echo "")
yellow=$(tput setaf 3 2>/dev/null || echo "")
green=$(tput setaf 2 2>/dev/null || echo "")
blue=$(tput setaf 4 2>/dev/null || echo "")

info() {
    printf "%s==> %s%s\n" "$blue" "$1" "$default_color"
}

success() {
    printf "%s==> %s%s\n" "$green" "$1" "$default_color"
}

error() {
    printf "%s==> %s%s\n" "$red" "$1" "$default_color" >&2
}

warning() {
    printf "%s==> %s%s\n" "$yellow" "$1" "$default_color"
}

# 平台检测
get_platform() {
    case "$(uname -s)" in
        Darwin) echo "osx" ;;
        Linux)  echo "linux" ;;
        *)      error "Unsupported platform: $(uname -s)" && exit 1 ;;
    esac
}

is_macos() { [[ "$(get_platform)" == "osx" ]]; }
is_linux() { [[ "$(get_platform)" == "linux" ]]; }

ZSHRC="$HOME/.zshrc"

# 检测是否为 Arch Linux
is_arch_linux() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        [[ "$ID" == "arch" ]]
    else
        return 1
    fi
}

append_to_zshrc_if_missing() {
    local line="$1"
    if ! grep -Fqx "$line" "$ZSHRC"; then
        echo "$line" >> "$ZSHRC"
        info "已向 $ZSHRC 追加: $line"
    fi
}
