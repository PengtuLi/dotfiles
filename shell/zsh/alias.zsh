################## alias ##################

# show all alias
alias ali=show_aliases

show_aliases(){
    alias -L | while read -r line; do
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
# alias f="spf -c ~/.config/superfile/config.toml --hotkey-file ~/.config/superfile/hotkeys.toml"
alias lg=lazygit

# ls
if command -v eza &>/dev/null; then
    alias ls="eza --color=always --icons=always"
    alias ll="eza -alhgM"
    alias tree="eza -alhgM --tree --level=3"
else
    alias ll="ls -alF"
fi

# ripgrep
alias rg="rg --pretty"
alias grep="rg"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Easier navigation: ..., ...., ....., and -
alias cd="z"
alias ..="cd ../"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# bat
alias b="bat --color=always -P -n"

# fzf
alias ff="fzf"
alias ff-p='fzf --preview="bat --color=always {}" \
    --height 80% --layout reverse --tmux'
alias ff-pm='fzf --multi --preview="bat --color=always {}" \
    --height 80% --layout reverse --tmux'

# macos window manage
# alias yb-s='yabai --start-service'
# alias yb-r='yabai --restart-service'
# alias yb-d='yabai --stop-service'
# alias sk-s='skhd --start-service'
# alias sk-r='skhd --restart-service'
# alias sk-d='skhd --stop-service'

# fastfetch
alias ft=fastfetch

# btop
alias bt=btop

# sleep
alias sleep="systemctl hybrid-sleep"

# cheatsheet
alias cht=cheatsh
alias cht-ls='cht :list | ff'

# ssh
alias s="ssh"
alias ss="TERM=xterm-256color ssh"
alias s-mihomo-forward="ssh -L 9190:localhost:9090"
alias s-kg="ssh-keygen -t rsa -b 4096"
alias s-kc="ssh-copy-id"
alias s-tc=ssh-terminfo-copy
alias s-kf=ssh-key-chmod-fix

alias 316-m="s zh-316-pc-mesh"
alias 316-f="s zh-316-pc-frp"
alias x299="ss x299-torch-16660"
alias x299-m="ss -J zh-316-pc-mesh x299-torch-16660"
alias x299-f="ss -J zh-316-pc-frp x299-torch-16660"

# nginx
alias ng-d="nginx -s stop"
alias ng-r="nginx -s reload"
alias ng="nginx"

# tmux
alias t='tmux attach -t default || tmux new -s default'
alias t-auto-on="touch ~/.tmux-auto-start"
alias t-auto-off="rm -f ~/.tmux-auto-start"
alias t-new='tmux new -s'
alias t-attach='tmux attach -t'
alias t-ls='tmux ls'
alias t-kill='tmux kill-session'
alias t-kill-server='tmux kill-server && rm -rf /tmp/tmux-*'
alias T="tmuxinator"
alias T-s="tmuxinator start"
alias T-S="tmuxinator stop"

# uv
alias uv-a=uv-activate

# proxy
alias sP=set_local_proxy
alias usP=unset_local_proxy
alias testP=test_proxy_all

alias ssP=set_system_proxy
alias unssP=unset_system_proxy

if which sudo &>/dev/null;then
    alias sPP="sudo mihomo -d /etc/mihomo"
else
    alias sPP="mihomo -d /etc/mihomo"
fi
alias P1="open http://board.zash.run.place/"
alias P2="open http://127.0.0.1:9090/ui"
alias P3="open yacd.haishan.me"
