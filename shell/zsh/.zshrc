# Get the dotfiles root directory
ZSH_DIR=${0:A:h}
DOTFILES_ROOT="$(git -C "$ZSH_DIR/../.." rev-parse --show-toplevel 2>/dev/null || echo "$ZSH_DIR/../..")"

# ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# 禁用 ctrl+d 解释的 eof
setopt IGNORE_EOF
# vi mode
bindkey -v

# ENV
# Load encrypted secrets if available
if [ -f "$DOTFILES_ROOT/shell/.env.secrets" ]; then
    set -a
    source "$DOTFILES_ROOT/shell/.env.secrets"
    set +a
fi
# export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim
export NVIM_SOCK="/tmp/lpt-nvim.sock"
# export TMUX_THEME=nord
export XDG_CONFIG_HOME="$HOME/.config" # useful for macos
export TERMINFO_DIRS="/usr/share/terminfo"
export SOPS_AGE_KEY="${_SOPS_AGE_KEY:-}"
export SOPS_AGE_SSH_PRIVATE_KEY_FILE=""
export HOMEBREW_NO_AUTO_UPDATE=1

# zsh history save
HISTFILE=~/.zsh_history #记录历史命令的文件
HISTSIZE=10000 #记录历史命令条数
SAVEHIST=10000
# 实时写入 + 会话间共享
setopt inc_append_history   # 每条命令立即写入文件
setopt share_history        # 所有 zsh 会话共享历史（可选，超实用！）
setopt hist_ignore_dups     # 忽略重复命令
setopt extended_history     # 记录时间戳（格式：:start_time:elapsed;command）

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

# zoxide
eval "$(zoxide init zsh)"

# atuin
eval "$(atuin init zsh --disable-up-arrow)"

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

autoload -Uz compinit && compinit

# Load shell modules
for lib in "$ZSH_DIR/lib"/*.zsh; do
    [ -r "$lib" ] && source "$lib"
done
[ -r "$ZSH_DIR/alias.zsh" ] && source "$ZSH_DIR/alias.zsh"
[ -r "$ZSH_DIR/zsh-unplugged.zsh" ] && source "$ZSH_DIR/zsh-unplugged.zsh"

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
