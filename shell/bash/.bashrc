# env
export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim
export NVIM_SOCK="/tmp/lpt-nvim.sock"
export HOMEBREW_NO_AUTO_UPDATE=true
export XDG_CONFIG_HOME="$HOME/.config"
export TERMINFO_DIRS="/usr/share/terminfo"
export HOMEBREW_NO_AUTO_UPDATE=1

HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend              # 追加而不是覆盖历史文件
shopt -s cmdhist                 # 多行命令保存为一行
export HISTCONTROL=ignoredups    # 忽略重复命令
export HISTIGNORE="[ ]*"         # 忽略以空格开头的命令
export HISTTIMEFORMAT=": %F %T: "
# 实时写入历史 + 多终端共享
__bash_history_sync() {
    history -a
    history -n
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}__bash_history_sync"

# 禁用 ctrl+d 退出
set -o ignoreeof

# 启用 vim 快捷键模式
set -o vi
# 根据模式切换光标形状 (插入:竖线 | 普通:块状)
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[6 q\2'
bind 'set vi-cmd-mode-string \1\e[2 q\2'

# 补全增强
shopt -s cdspell       # cd 拼写纠错
shopt -s dirspell      # 目录名拼写纠错
shopt -s checkwinsize  # 检查窗口大小变化
shopt -s autocd        # 自动 cd（输入目录名直接进入）

# bash_completion load
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# 设置文件类型颜色（用于 ls 和补全）
eval "$(dircolors)"
# 补全行为优化（必须在 bash_completion 之后设置）
bind "set completion-ignore-case on"        # 忽略大小写
bind "set completion-map-case on"           # 连字符和下划线等价
bind "set show-all-if-ambiguous on"         # 直接显示所有选项
bind "set colored-stats on"                 # 彩色显示
bind "set visible-stats on"                 # 显示文件类型符
bind "set colored-completion-prefix on"     # 高亮匹配前缀
# ==================================================
# 别名
# ==================================================
# show all alias
alias ali=show_aliases

show_aliases() {
    alias | while read -r line; do
        alias_name="${line%%=*}"
        alias_command="${line#*=}"
        # 计算虚线长度
        dash_length=$((20 - ${#alias_name}))
        dashes=$(printf '%*s' "$dash_length" | tr ' ' '-')
        printf "\033[31m%-s\033[0m \033[37m%s\033[0m \033[32m%s\033[0m\n" "$alias_name" "$dashes" "$alias_command"
    done
}

# Base
alias ln="ln -v"
alias md="mkdir -p"
alias e=$EDITOR
alias E="$EDITOR --listen $NVIM_SOCK"
alias v=$VISUAL
alias c=clear
alias pst=pstree
alias path='echo $PATH | tr -s ":" "\n"'

# 快速目录跳转
if command -v zoxide >/dev/null 2>&1; then
    alias cd="z"
fi
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....="cd ../../../.."
alias -- -="cd -"

# ls 增强
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lt='ls -altr'  # 按时间排序

# grep 彩色
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rg="rg --pretty"

# disk
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias dus='du -sh * | sort -h'  # 当前目录大小排序

# 安全操作
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# fzf
alias f="fzf"
alias f-p='fzf --preview="bat --color=always {}" \
    --height 80% --layout reverse --tmux'
alias f-pm='fzf --multi --preview="bat --color=always {}" \
    --height 80% --layout reverse --tmux'

# wget 断点续传
alias wget='wget -c'

# uv
alias uv-a=uv-activate

# git
alias lg=lazygit
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gbc='git checkout'

# tmux
alias t='tmux attach -t default || tmux new -s default'
alias t-auto-on="touch ~/.tmux-auto-start"
alias t-auto-off="rm -f ~/.tmux-auto-start"
alias t-new='tmux new -s'
alias t-attach='tmux attach -t'
alias t-ls='tmux ls'
alias t-kill='tmux kill-session -t'
alias t-kill-server='tmux kill-server'
alias T="tmuxinator"
alias T-s="tmuxinator start"
alias T-S="tmuxinator stop"

# ==================================================
# 实用函数
# ==================================================
# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}
alias mc=mkcd

# 查找并杀死进程
killps() {
    ps aux | grep -i "$1" | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null
}
alias kp=killps

# 快速备份文件
backup() {
    local file="$1"
    if [ -e "$file" ]; then
        cp -r "$file" "$file.bak_$(date +%Y%m%d_%H%M%S)"
        echo "Backed up $file to $file.bak_$(date +%Y%m%d_%H%M%S)"
    else
        echo "Error: $file does not exist"
        return 1
    fi
}
alias bak=backup

# 提取各种压缩文件
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
alias ext=extract

# 查找文件并显示
ffind() {
    find . -type f -name "*$1*"
}
alias ff=ffind

# 查找目录并显示
dfind() {
    find . -type d -name "*$1*"
}
alias fd=dfind

# 统计代码行数
lines() {
    find . -name "*.$1" | xargs wc -l | tail -1
}
alias loc=lines

# 端口占用检查
port() {
    lsof -i :"$1" 2>/dev/null || netstat -tuln | grep "$1"
}
alias pt=port

# ==================================================
# 提示符
# ==================================================
# 显示 git 分支
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
COLOR_PROMPT=on
# 基础提示符（带 git 分支）
if [ "$COLOR_PROMPT" = on ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;33m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='\u@\h:\w$(parse_git_branch)\$ '
fi

# ==================================================
# 其他实用设置
# ==================================================
# LESS 颜色支持
export LESS='-R'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# GPG TTY
export GPG_TTY=$(tty)

# ==================================================
# 工具集成
# ==================================================
export PATH="$HOME/.local/bin:$PATH"

# thefuck
if command -v thefuck >/dev/null 2>&1; then
    eval $(thefuck --alias)
    eval $(thefuck --alias fk)
fi

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
    eval "$(fzf --bash)"
fi

# rg
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion bash)"
fi

# Yazi with cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# Tmux auto-start
if command -v tmux >/dev/null 2>&1; then
    if [ -z "$TMUX" ] && [ -e ~/.tmux-auto-start ]; then
        tmux attach -t default || tmux new -s default
    fi
fi

# uv find recursively to parent
uv-activate() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/.venv/bin/activate" ]]; then
            echo "Activating virtual environment: $dir/.venv"
            source "$dir/.venv/bin/activate"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "No .venv found in any parent directory." >&2
    return 1
}
