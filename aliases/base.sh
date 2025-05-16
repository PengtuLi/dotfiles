# ENV
# export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=code
export TMUX_THEME=nord
export HOMEBREW_NO_AUTO_UPDATE=true

alias ali=show_aliases

# Unix
alias ll="ls -al"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e=$EDITOR
alias v=$VISUAL
alias c=clear

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Easier navigation: ..., ...., ....., and -
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

alias s=ssh
alias t=tmux
alias t-dS='tmux kill-server && rm -rf /tmp/tmux-*'
alias t-ds='tmux kill-session'
alias t-a='tmux attach -t'
alias autol=autoliter
alias f=spf
alias lg=lazygit
alias b="bat --color=always"

alias ff="fzf"
alias ff-p='fzf --preview="bat --color=always {}"'
alias ff-pm='fzf --multi --preview="bat --color=always {}"'

alias yb-s='yabai --start-service'
alias yb-r='yabai --restart-service'
alias yb-d='yabai --stop-service'
alias sk-s='skhd --start-service'
alias sk-r='skhd --restart-service'
alias sk-d='skhd --stop-service'

# Include custom aliases
# alias_path=$(readlink -f ~/mylink)
# if [[ -f ./proxy.aliases ]]; then
#   echo exist
#   source ./proxy.aliases
# fi
#

show_aliases(){
    alias | while read -r line; do
        alias_name="${line%%=*}"
        alias_command="${line#*=}"
        # 计算虚线长度
        dash_length=$((20 - ${#alias_name}))
        dashes=$(printf '%*s' "$dash_length" | tr ' ' '-')
        printf "\033[31m%-s\033[0m \033[37m%s\033[0m \033[32m%s\033[0m\n" "$alias_name" "$dashes" "$alias_command"
    done
}
