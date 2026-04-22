# Load shared aliases
[ -r "$SHELL_DIR/../common/alias.sh" ] && source "$SHELL_DIR/../common/alias.sh"

################## zsh-only aliases ##################

# sleep
alias sleep="systemctl hybrid-sleep"

# ssh
alias s="ssh"
alias S="TERM=xterm-256color ssh"
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
