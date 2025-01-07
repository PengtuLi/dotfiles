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
    error "有效预设: macos, linux-gui, linux-tty, linux-container"
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

# autojump, legacy
# if ! command -v autojump &>/dev/null; then
#     git clone https://github.com/wting/autojump.git ~/.zsh/autojump
#     cd  ~/.zsh/autojump
#     python3 ~/.zsh/autojump/install.py
#     append_to_zshrc_if_missing '[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh'
# else
#     warning "autojump has already installed"
# fi

# # zoxide
# if command -v starship &>/dev/null; then
#     append_to_zshrc_if_missing '# zoxide'
#     append_to_zshrc_if_missing 'eval "$(zoxide init zsh)"'
# fi
#
# # fzf
# if [ ! -d "$HOME/.fzf" ]; then
#     git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#     ${HOME}/.fzf/install --key-bindings --completion
#     cat >> "$ZSHRC" <<'EOF'
# # --------- set fzf ----------
# if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
#   PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
#   source <(fzf --zsh)
# fi
# # --------- end fzf ----------
# EOF
# fi

# # starship prompt 初始化
# if command -v starship &>/dev/null; then
#     append_to_zshrc_if_missing 'eval "$(starship init zsh)"'
# fi
#
# # thefuck 命令修正
# if command -v thefuck &>/dev/null; then
#     append_to_zshrc_if_missing 'eval $(thefuck --alias)'
#     append_to_zshrc_if_missing 'eval $(thefuck --alias fk)'
# fi

# fastfetch
# if command -v fastfetch &>/dev/null; then
#     if ! grep -Fxq 'if [ ! -n "$TMUX" ]; then' "$ZSHRC" || \
    #         ! grep -Fxq '    fastfetch' "$ZSHRC" || \
    #         ! grep -Fxq 'fi' "$ZSHRC"; then
#         cat >> "$ZSHRC" << 'EOF'
#
# # Add fastfetch in tmux
# if [ ! -n "$TMUX" ]; then
#     fastfetch
# fi
#
# EOF
#         info "已向 $ZSHRC 追加 fastfetch TMUX 检测配置"
#     fi
# fi

# ----------------------------------------------
