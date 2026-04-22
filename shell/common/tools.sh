# Shared tool integrations (shell-aware)

# Detect current shell
_current_shell() {
    if [ -n "$ZSH_VERSION" ]; then echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then echo "bash"
    fi
}

# thefuck
if command -v thefuck >/dev/null 2>&1; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init $(_current_shell))"
fi

# uv shell completion
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion $(_current_shell))"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="
-m
--info default
--prompt='🔍 '
--pointer='👉'
--bind 'ctrl-space:toggle+down'
--bind 'ctrl-j:down,ctrl-k:up'
--bind 'ctrl-n:down,ctrl-p:up'
--bind 'ctrl-d:half-page-down,ctrl-u:half-page-up'
--bind 'ctrl-f:page-down,ctrl-b:page-up'
--bind 'ctrl-alt-d:preview-half-page-down,ctrl-alt-u:preview-half-page-up'
--bind 'ctrl-alt-f:preview-page-down,ctrl-alt-b:preview-page-up'
--bind 'ctrl-\\:toggle-preview'
--bind 'alt-a:toggle-all'
"
    case "$(_current_shell)" in
        bash) eval "$(fzf --bash)" ;;
        zsh) FZF_ALT_C_COMMAND= FZF_CTRL_R_COMMAND= eval "$(fzf --zsh)" ;;
    esac
fi
