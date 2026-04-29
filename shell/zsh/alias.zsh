# Load shared aliases
[ -r "$SHELL_DIR/../common/alias.sh" ] && source "$SHELL_DIR/../common/alias.sh"

################## zsh-only aliases ##################

# sleep
alias sleep="systemctl hybrid-sleep"

# ssh
alias s="ssh"
alias S="TERM=xterm-256color ssh"
alias px-fwd="ssh -L 9190:localhost:9090"
alias s-kg="ssh-keygen -t rsa -b 4096"
alias s-kc="ssh-copy-id"
alias s-tc=ssh-terminfo-copy
alias s-kf=ssh-key-chmod-fix

alias 316-m="s zh-316-pc-mesh"
alias 316-f="s zh-316-pc-frp"
alias x299="ss x299-torch-16660"
alias x299-m="ss -J zh-316-pc-mesh x299-torch-16660"
alias x299-f="ss -J zh-316-pc-frp x299-torch-16660"

if which sudo &>/dev/null;then
    alias pxd="sudo mihomo -d /etc/mihomo"
else
    alias pxd="mihomo -d /etc/mihomo"
fi
alias px-board="open http://board.zash.run.place/"
alias px-ui="open http://127.0.0.1:9090/ui"
alias px-yacd="open yacd.haishan.me"
