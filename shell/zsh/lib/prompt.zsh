# 保存上一次是否在 SSHFS 的状态
_LAST_IN_SSHFS="unknown"
_in_sshfs() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if mount -t fuse.sshfs 2>/dev/null | command grep -qF " $dir "; then
            return 0
        fi
        dir="${dir:h}"
    done
    return 1
}
_update_prompt() {
    if _in_sshfs; then
        export STARSHIP_DISABLE=1
        setopt PROMPT_SUBST
        autoload -U colors && colors
        PROMPT="%{$fg[green]%}%n%{$reset_color%}@%{$fg[blue]%}%m%{$reset_color%}:%{$fg[yellow]%}%~%{$reset_color%}\$ "
        _LAST_IN_SSHFS=1
    else
        unset STARSHIP_DISABLE
        eval "$(starship init zsh --print-full-init)"
        _LAST_IN_SSHFS=0
    fi
}
# 初始设置
_update_prompt
chpwd() {
    local currently_in_sshfs
    if _in_sshfs; then
        currently_in_sshfs=1
    else
        currently_in_sshfs=0
    fi
    # 仅当状态改变时更新 prompt
    if [[ "$_LAST_IN_SSHFS" != "$currently_in_sshfs" ]]; then
        _update_prompt
    fi
}
