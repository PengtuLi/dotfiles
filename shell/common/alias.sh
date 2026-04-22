# Shared aliases (POSIX compatible)

# show all alias
alias ali=show_aliases

# Base
alias ln="ln -v"
alias md="mkdir -p"
alias e=$EDITOR
alias E="$EDITOR --listen $NVIM_SOCK"
alias v=$VISUAL
alias c=clear
alias path='echo $PATH | tr -s ":" "\n"'

# Navigation
if command -v zoxide >/dev/null 2>&1; then
    alias cd="z"
fi
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# bat
alias b="bat --color=always -P -n"

# ripgrep / grep
if command -v rg >/dev/null 2>&1; then
    alias grep="rg --pretty"
else
    alias grep="grep --color=auto"
fi

# find
if command -v fd >/dev/null 2>&1; then
  alias find="fd"
fi

# ls
if command -v eza &>/dev/null; then
    alias ls="eza --color=always --icons=always"
    alias ll="eza -alhgM"
    alias tree="eza -alhgM --tree --level=3"
else
    alias ls="ls --color=auto"
    alias ll="ls -alF"
    alias la="ls -A"
    alias l="ls -CF"
    alias lt="ls -altr"
fi

# monitor
if command -v btop >/dev/null 2>&1; then
    alias top="btop"
    alias htop="btop"
fi

# disk
alias free="free -h"
if command -v duf >/dev/null 2>&1; then
    alias df="duf"
else
    alias df="df -h"
fi
if command -v dust >/dev/null 2>&1; then
    alias du="dust"
else
    alias du="du -h"
    alias dus="du -sh * | sort -h"
fi

# fastfetch
alias ft=fastfetch

# onefetch
alias of=onefetch

# procs (modern ps)
if command -v procs >/dev/null 2>&1; then
    alias ps="procs"
    alias pst="procs --tree"           # tree view
    alias psw="procs --watch"          # watch mode (like top)
    alias psu="procs $(whoami)"        # show my processes only
fi

# gping (ping with graph)
if command -v gping >/dev/null 2>&1; then
    alias Ping="gping"
fi

# sd (search & displace, modern sed)
if command -v sd >/dev/null 2>&1; then
    alias sdp="sd -p"     # preview mode
    alias sdf="sd -F"     # fixed-string (literal) mode
fi

# hyperfine (benchmark)
alias hf="hyperfine --warmup 3"

# tldr (simplified man)
alias tl="tldr"

# tokei (code stats)
alias loc="tokei"

# safety
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# fzf
alias ff="fzf"
alias ff-p='fzf --preview="bat --color=always {}" --height 80% --layout reverse --tmux'
alias ff-pm='fzf --multi --preview="bat --color=always {}" --height 80% --layout reverse --tmux'

# nginx
alias ng-d="nginx -s stop"
alias ng-r="nginx -s reload"
alias ng="nginx"

# wget
alias wget="wget -c"

# git
alias lg="lazygit"
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gbc="git checkout"

# tmux
alias t="tmux attach -t default || tmux new -s default"
alias t-auto-on="touch ~/.tmux-auto-start"
alias t-auto-off="rm -f ~/.tmux-auto-start"
alias t-new="tmux new -s"
alias t-attach="tmux attach -t"
alias t-ls="tmux ls"
alias t-kill-server="tmux kill-server && rm -rf /tmp/tmux-*"
alias T="tmuxinator"
alias T-s="tmuxinator start"
alias T-S="tmuxinator stop"

# uv
alias uv-a=uv-activate

# cheatsheet
alias cht=cheatsh
alias cht-ls="cht :list | ff"

# function aliases (so they show up in `ali`)
alias backup=backup
alias extract=extract
alias port=port
alias y=y
