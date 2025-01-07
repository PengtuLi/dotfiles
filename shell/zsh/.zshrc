# Ghostty shell integration for Bash. This should be at the top of your bashrc!
if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# ENV
# export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim
# export TMUX_THEME=nord
export HOMEBREW_NO_AUTO_UPDATE=true
export XDG_CONFIG_HOME="$HOME/.config" # useful for macos
export TERMINFO_DIRS="/usr/share/terminfo"
export SOPS_AGE_KEY="$(cat ~/.age.key)"
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


# starship
eval "$(starship init zsh)"

eval $(thefuck --alias)
eval $(thefuck --alias fk)

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}${HOME}/.fzf/bin"
    source <(fzf --zsh)
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
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

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
