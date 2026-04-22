# Load shared environment
SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -r "$SHELL_DIR/common/env.sh" ] && source "$SHELL_DIR/common/env.sh"

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
# aliases
# ==================================================

# Load shared aliases
[ -r "$SHELL_DIR/common/alias.sh" ] && source "$SHELL_DIR/common/alias.sh"

# ==================================================
# bash-only
# ==================================================

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
