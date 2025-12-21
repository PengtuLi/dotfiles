# Ghostty shell integration for zsh. This should be at the top of your bashrc!
# if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
#     builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
# fi

# ENV
# export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim
export NVIM_SOCK="/tmp/lpt-nvim.sock"
# export TMUX_THEME=nord
export HOMEBREW_NO_AUTO_UPDATE=true
export XDG_CONFIG_HOME="$HOME/.config" # useful for macos
export TERMINFO_DIRS="/usr/share/terminfo"
export SOPS_AGE_KEY=$_SOPS_AGE_KEY
export SOPS_AGE_SSH_PRIVATE_KEY_FILE=""


# zsh history save
HISTFILE=~/.zsh_history #记录历史命令的文件
HISTSIZE=10000 #记录历史命令条数
SAVEHIST=10000
# 实时写入 + 会话间共享
setopt inc_append_history   # 每条命令立即写入文件
setopt share_history        # 所有 zsh 会话共享历史（可选，超实用！）
setopt hist_ignore_dups     # 忽略重复命令
setopt extended_history     # 记录时间戳（格式：:start_time:elapsed;command）

# 保存上一次是否在 SSHFS 的状态
_LAST_IN_SSHFS="unknown"
_in_sshfs() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if mount -t fuse.sshfs 2>/dev/null | command grep -qF " $dir "; then
            return 0
        fi
        dir="${dir:h}"
    done
    return 1
}
_update_prompt() {
    if _in_sshfs; then
        export STARSHIP_DISABLE=1
        setopt PROMPT_SUBST
        autoload -U colors && colors
        PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[blue]%}%m%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}\$ "
        _LAST_IN_SSHFS=1
    else
        unset STARSHIP_DISABLE
        eval "$(starship init zsh --print-full-init)"
        _LAST_IN_SSHFS=0
    fi
}
# 初始设置
_update_prompt
chpwd() {
    local currently_in_sshfs
    if _in_sshfs; then
        currently_in_sshfs=1
    else
        currently_in_sshfs=0
    fi
    # 仅当状态改变时更新 prompt
    if [[ "$_LAST_IN_SSHFS" != "$currently_in_sshfs" ]]; then
        _update_prompt
    fi
}

eval $(thefuck --alias)
eval $(thefuck --alias fk)

# fzf
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
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
    PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
    FZF_ALT_C_COMMAND= source <(fzf --zsh)
fi

# antidote
# source ~/.zsh/antidote/antidote.zsh
# antidote load

# zoxide
eval "$(zoxide init zsh)"

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

# 全局启用：即使未输入 - 或 --，也显示所有选项
zstyle ':completion:*:*:*:*' complete-options true
# 可选：显示补全描述和分组（配合 fzf-tab 更清晰）
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

zstyle ':fzf-tab:*' use-fzf-default-opts yes
# preview content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'bat --color=always $realpath'
# custom fzf flags
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-space:toggle+down'
zstyle ':fzf-tab:*' continuous-trigger ''


autoload -Uz compinit && compinit

# clone-only plugins
# plugin-clone 'romkatv/zsh-bench@d7f9f821688bdff9365e630a8aaeba1fd90499b1'
# path+=$ZPLUGINDIR/romkatv/zsh-bench

# load plugins
plugins=(
    # Uncomment to load your custom zstyles.
    # $ZDOTDIR/.zpreztorc
    # $ZDOTDIR/.zstyles

    # Uncomment to use your local plugins
    # Put these in $ZDOTDIR/plugins
    # my_plugin
    # python

    # Completions
    # marlonrichert/zsh-autocomplete
    aloxaf/fzf-tab
    zsh-users/zsh-completions
    zsh-users/zsh-autosuggestions

    # util
    zsh-users/zsh-syntax-highlighting
    MichaelAquilina/zsh-you-should-use
)
plugin-load $plugins
