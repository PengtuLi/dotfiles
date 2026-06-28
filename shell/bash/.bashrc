# Load shared environment
SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -r "$SHELL_DIR/common/env.sh" ] && source "$SHELL_DIR/common/env.sh"

HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend              # 追加而不是覆盖历史文件
shopt -s cmdhist                 # 多行命令保存为一行
export HISTCONTROL=ignoredups    # 忽略重复命令
# export HISTIGNORE="[ ]*"         # 忽略以空格开头的命令
# 忽略完全由空格组成的命令
HISTIGNORE="${HISTIGNORE:+${HISTIGNORE}:}  *"
export HISTTIMEFORMAT=": %F %T: "
# 实时写入历史 + 多终端共享
__bash_history_sync() {
    history -a
    history -c
    history -r
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND;}__bash_history_sync"

# 禁用 ctrl+d 退出
set -o ignoreeof

# 启用 vim 快捷键模式
set -o vi
# 根据模式切换光标形状 (插入:闪烁方块 | 普通:方块)
bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string \1\e[1 q\2'
bind 'set vi-cmd-mode-string \1\e[2 q\2'

# 补全增强
shopt -s cdspell       # cd 拼写纠错
shopt -s dirspell      # 目录名拼写纠错
shopt -s checkwinsize  # 检查窗口大小变化
shopt -s autocd        # 自动 cd（输入目录名直接进入）

# bash_completion load
[[ -r "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh" ]] && . "/home/linuxbrew/.linuxbrew/etc/profile.d/bash_completion.sh"

# 设置文件类型颜色（用于 ls 和补全）
if command -v dircolors &>/dev/null; then
    eval "$(dircolors)"
elif command -v gdircolors &>/dev/null; then
    eval "$(gdircolors)"
fi
# 补全行为优化（必须在 bash_completion 之后设置）
bind "set completion-ignore-case on"        # 忽略大小写
bind "set completion-map-case on"           # 连字符和下划线等价
bind "set show-all-if-ambiguous on"         # 直接显示所有选项
bind "set colored-stats on"                 # 彩色显示
bind "set visible-stats on"                 # 显示文件类型符
bind "set colored-completion-prefix on"     # 高亮匹配前缀

# ==================================================
# aliases
# ==================================================

# Load shared aliases
[ -r "$SHELL_DIR/common/alias.sh" ] && source "$SHELL_DIR/common/alias.sh"

# ==================================================
# bash-only
# ==================================================

# Simple history search (fzf fallback)
# Only active when fzf is not installed
__fh_search() {
    local query=""
    local tmpfile
    tmpfile=$(mktemp)

    # Build full candidate list once
    history | awk '
        {
            sub(/^[ ]*[0-9]+[ ]+/, "");
            sub(/^:[ ]*[0-9]{4}-[0-9]{2}-[0-9]{2}[ ][0-9]{2}:[0-9]{2}:[0-9]{2}[ ]*:[ ]*/, "");
            if (!seen[$0]++) { a[++n]=$0 }
        }
        END { for(i=n;i>=1;i--) print a[i] }
    ' > "$tmpfile"

    local old_stty
    old_stty=$(stty -g)
    stty -echo -icanon min 1 time 0

    local selected=""
    while true; do
        # Filter candidates by current query
        local candidates
        if [ -n "$query" ]; then
            candidates=$(grep -F "$query" "$tmpfile" 2>/dev/null)
        else
            candidates=$(cat "$tmpfile")
        fi

        # Draw without clearing screen
        echo "history search: $query" >&2
        echo "---" >&2
        echo "" >&2

        if [ -z "$candidates" ]; then
            echo "  (no matches)" >&2
        else
            echo "$candidates" | head -n 10 | awk '{ printf "  \033[36m%2d\033[0m  %s\n", NR, $0 }' >&2
        fi
        echo "" >&2
        echo "  type to filter, 1-9=select, enter=1st, q/esc/ctrl-c=quit" >&2

        local key
        key=$(dd bs=1 count=1 2>/dev/null)

        # Debug
        printf "key_hex=" > /tmp/fh_debug.log
        printf '%s' "$key" | xxd -p >> /tmp/fh_debug.log
        printf " key_len=%d\n" "${#key}" >> /tmp/fh_debug.log

        case "$key" in
            $'\x7f'|$'\b')
                echo "backspace" >> /tmp/fh_debug.log
                query="${query%?}"
                ;;
            $'\e')
                echo "esc" >> /tmp/fh_debug.log
                stty "$old_stty"
                rm -f "$tmpfile"
                echo "" >&2
                return 1
                ;;
            q|Q|$'\x03')
                echo "quit" >> /tmp/fh_debug.log
                stty "$old_stty"
                rm -f "$tmpfile"
                echo "" >&2
                return 1
                ;;
            $'\r'|$'\n')
                echo "enter" >> /tmp/fh_debug.log
                if [ -n "$candidates" ]; then
                    selected=$(echo "$candidates" | head -n 1)
                    echo "selected=$selected" >> /tmp/fh_debug.log
                    break
                fi
                ;;
            [1-9])
                echo "num=$key" >> /tmp/fh_debug.log
                local count
                count=$(echo "$candidates" | head -n 10 | wc -l | tr -d ' ')
                if [ "$key" -le "$count" ] 2>/dev/null; then
                    selected=$(echo "$candidates" | sed -n "${key}p")
                    echo "selected=$selected" >> /tmp/fh_debug.log
                    break
                fi
                ;;
            *)
                echo "other='$key'" >> /tmp/fh_debug.log
                query="${query}${key}"
                ;;
        esac
    done

    stty "$old_stty"
    rm -f "$tmpfile"

    echo "final selected='$selected'" >> /tmp/fh_debug.log
    if [ -n "$selected" ]; then
        READLINE_LINE="$selected"
        READLINE_POINT=${#selected}
        echo "set READLINE_LINE" >> /tmp/fh_debug.log
    fi
}

# Bind Ctrl+R only if fzf is not available (fzf's key-bindings will override otherwise)
if ! command -v fzf &>/dev/null; then
    bind -x '"\C-r": __fh_search'
fi

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
# tools
# ==================================================
# Load shared functions
[ -r "$SHELL_DIR/common/function.sh" ] && source "$SHELL_DIR/common/function.sh"

# Load shared tools
[ -r "$SHELL_DIR/common/tools.sh" ] && source "$SHELL_DIR/common/tools.sh"
