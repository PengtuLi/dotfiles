# Load shared aliases
[ -r "$SHELL_DIR/../common/alias.sh" ] && source "$SHELL_DIR/../common/alias.sh"

################## zsh-only aliases ##################

# sleep
alias sleep="systemctl hybrid-sleep"

# ssh host
alias 316-m="s zh-316-pc-mesh"
alias 316-f="s zh-316-pc-frp"
alias x299="ss x299-torch-16660"
alias x299-m="ss -J zh-316-pc-mesh x299-torch-16660"
alias x299-f="ss -J zh-316-pc-frp x299-torch-16660"
