SHELL_DIR=${0:A:h}

# Load shared environment
[ -r "$SHELL_DIR/../common/env.sh" ] && source "$SHELL_DIR/../common/env.sh"

# 禁用 ctrl+d 解释的 eof
setopt IGNORE_EOF
# vi mode
bindkey -v

# Load encrypted secrets if available
if [ -f "$SHELL_DIR/.env.secrets" ]; then
    set -a
    source "$SHELL_DIR/.env.secrets"
    set +a
fi

# zsh-only env
export SOPS_AGE_KEY="${_SOPS_AGE_KEY:-}"
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

# atuin - must be loaded after all plugins
zvm_after_init_commands+=(
    eval "$(atuin init zsh --disable-up-arrow)"
)

# fzf-tab
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

# zsh vi util
export ZVM_VI_SURROUND_BINDKEY=s-prefix

autoload -Uz compinit && compinit

# Load shared tools (after compinit, thefuck needs compdef)
[ -r "$SHELL_DIR/../common/tools.sh" ] && source "$SHELL_DIR/../common/tools.sh"

# Load shared functions
[ -r "$SHELL_DIR/../common/function.sh" ] && source "$SHELL_DIR/../common/function.sh"

# Load shell modules
for lib in "$SHELL_DIR/lib"/*.zsh; do
    [ -r "$lib" ] && source "$lib"
done
[ -r "$SHELL_DIR/alias.zsh" ] && source "$SHELL_DIR/alias.zsh"
[ -r "$SHELL_DIR/zsh-unplugged.zsh" ] && source "$SHELL_DIR/zsh-unplugged.zsh"

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
    jeffreytse/zsh-vi-mode
)
plugin-load $plugins
