# Shared aliases (POSIX compatible)

# show all alias
alias ali=show_aliases

# Base
alias ln="ln -v"
alias md="mkdir -p"
alias e=$EDITOR
alias E="$EDITOR --listen $NVIM_SOCK"     # connect to running nvim instance (used with nvim --server)
alias v=$VISUAL
alias c=clear
alias path='echo $PATH | tr -s ":" "\n"'  # print PATH one entry per line

# Navigation
if command -v zoxide >/dev/null 2>&1; then
    alias cd="z"
fi
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"                             # back to previous directory (-- required: - starts with dash)

# bat
alias b="bat --color=always -P -n"          # -P: no paging, -n: show line numbers

# ripgrep / grep
if command -v rg >/dev/null 2>&1; then
    alias grep="rg --pretty"
    #   rga: include hidden files (still respects .gitignore)
    #       $ rga todo             → also searches .config/, .envrc, etc.
    alias rga="rg --hidden"
    #   rgA: search EVERYTHING — hidden files + ignore .gitignore
    #       $ rgA password         → finds secrets in .env, build/, node_modules/
    alias rgA="rg --hidden --no-ignore"
    #   rgf: fixed-string — no regex parsing (escape-free for special chars)
    #       $ rgf "error.*handler" → matches literally "error.*handler", not as regex
    #       $ rgf "$HOME/.config"  → matches literally "$HOME/.config"
    alias rgf="rg -F"
    #   rgl: list matching filenames only (useful for piping)
    #       $ rgl TODO             → outputs: src/main.rs, lib/parser.rs
    #       $ rgl deprecated | xargs sed -i 's/deprecated/legacy/g'
    alias rgl="rg -l"
    #   rgw: whole-word match — won't match substrings
    #       $ rgw port             → matches "port" but NOT "export", "portable", "support"
    alias rgw="rg -w"
    #   rgc: count matches per file — quick heatmap of where pattern is densest
    #       $ rgc error            → src/main.rs:3, lib/db.rs:12, test/api.rs:0
    alias rgc="rg -c"
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
    alias ll="eza -alhgM"                           # long listing
    alias la="eza -a"                                # all files including hidden
    alias lt="eza -alhgM --sort=modified --reverse"  # long, by mtime (newest last)
    alias tree="eza -alhgM --tree --level=3"         # tree view, depth 3
else
    alias ls="ls --color=auto"
    alias ll="ls -alF"                               # long listing
    alias la="ls -A"                                 # all except . and ..
    alias lt="ls -altr"                              # long, by mtime (newest last)
    if command -v tree >/dev/null 2>&1; then
        alias tree="tree -C --dirsfirst"              # colorized, dirs first
    fi
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
    alias dus="du -sh * | sort -h"              # summary of each item, sorted by size
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

# witr (process ancestry tracer)
if command -v witr >/dev/null 2>&1; then
    alias wt="witr"                    # inspect process with full details
    alias wtt="witr --tree"            # show process ancestry tree only
    alias wtp="witr --port"            # find process by port (usage: wtp 8080)
fi

# doggo (modern dig)
if command -v doggo >/dev/null 2>&1; then
    alias dns="doggo"
    alias dnsx="doggo -x"                     # reverse DNS lookup
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

# yq
alias yq="yq -C"                            # color output

# safety (confirm before overwrite/remove)
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# fzf
alias ff="fzf"
alias ff-p='fzf --preview="bat --color=always {}" --height 80% --layout reverse --tmux'  # fzf with bat preview in tmux popup
alias ff-pm='fzf --multi --preview="bat --color=always {}" --height 80% --layout reverse --tmux' # multi-select with bat preview

# nginx
alias ng-d="nginx -s stop"
alias ng-r="nginx -s reload"
alias ng="nginx"

# wget
alias wget="wget -c"                        # -c: resume interrupted downloads

# git
alias Lg="gitui"
alias lg="lazygit"
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull --rebase"              # rebase to avoid merge commits
alias gd="git diff"
alias gb="git branch"
alias gbc="git switch"                    # switch branch (replaces checkout for branching)
alias gsw="git switch"                    # alias for gbc
alias grs="git restore"                   # restore file (replaces checkout for files)
alias glog="git log --oneline --graph --decorate -20"

# herdr
# h() {
#     if ! command -v tmux >/dev/null 2>&1; then
#         herdr
#         return
#     fi
#
#     # Check if there's already a herdr window in the default session
#     local herdr_window
#     herdr_window=$(tmux list-windows -t default -F '#{window_index}:#{window_name}' 2>/dev/null | awk -F: '$2 == "herdr" {print $1; exit}')
#
#     if [ -n "$herdr_window" ]; then
#         # Herdr window exists — switch to it
#         if [ -n "$TMUX" ]; then
#             tmux select-window -t "default:$herdr_window"
#         else
#             tmux attach -t "default:$herdr_window"
#         fi
#     elif [ -n "$TMUX" ]; then
#         # Inside tmux, create new window at index 0
#         tmux new-window -n herdr -t default:0 herdr
#     else
#         # Outside tmux: try to create new session with herdr at window 0, or create window in existing default session
#         if ! tmux new-session -s default -n herdr -d herdr 2>/dev/null; then
#             tmux new-window -n herdr -t default:0 herdr
#         fi
#         tmux attach -t default
#     fi
# }
# alias h=h

# tmux
alias t="tmux attach -t default || tmux new -s default"  # attach or create default session
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
alias cht-ls="cht :list | ff"              # list all cheatsheets, pipe to fzf

# vibe-coding
alias Claude="IS_SANDBOX=1 claude --dangerously-skip-permissions"
alias claude-vl="uv-a && IS_SANDBOX=1 CLAUDE_CODE_EFFORT_LEVEL=max claude --settings ~/.claude/settings_vl.json --dangerously-skip-permissions"
alias claude-gpt="IS_SANDBOX=1 CLAUDE_CODE_EFFORT_LEVEL=max claude --settings ~/.claude/settings_gpt.json --dangerously-skip-permissions"
alias qs="cd vibe-love || claude-vl"

# easytier (mesh VPN)
if command -v easytier-cli >/dev/null 2>&1; then
    alias et="easytier-cli"             # cli entry
    alias et-st="et_status"             # show node + peers + routes overview
fi

# fail2ban
alias f2b-et="sudo fail2ban-client status easytier"
alias f2b-sshd="sudo fail2ban-client status sshd"
alias f2b-all="sudo fail2ban-client status"
alias f2b-log="sudo tail -n 200 /var/log/fail2ban.log"

# proxy
alias px=set_local_proxy
alias px-u=unset_local_proxy
alias px-s=set_system_proxy
alias px-us=unset_system_proxy
if which sudo &>/dev/null;then
    alias pxd="sudo mihomo -d /etc/mihomo"
else
    alias pxd="mihomo -d /etc/mihomo"
fi
# proxy web ui
alias px-web-metacubex="open http://127.0.0.1:9090/ui"
alias px-web-zash="open http://board.zash.run.place/"
alias px-web-yacd="open yacd.haishan.me"

# function aliases (registered so they show up in `ali`)
alias backup=backup
alias extract=extract
alias compress=compress
alias port=port
alias y=y

# ssh
alias s="TERM=xterm-256color ssh"
alias px-fwd="ssh -L 9190:localhost:9090"
alias s-kg="ssh-keygen -t rsa -b 4096"
alias s-kc="ssh-copy-id"
