# Shared environment variables (POSIX compatible)

# local bin path
export PATH="$HOME/.local/bin:$PATH"

export EDITOR=nvim
export VISUAL=nvim
export NVIM_SOCK="/tmp/lpt-nvim.sock"
export XDG_CONFIG_HOME="$HOME/.config"
export TERMINFO_DIRS="/usr/share/terminfo"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export GPG_TTY=$(tty)

# LESS color support
export LESS='-R'
export LESS_TERMCAP_mb=$'\E[1;31m'
export LESS_TERMCAP_md=$'\E[1;36m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$'\E[1;32m'
export LESS_TERMCAP_ue=$'\E[0m'

# LANG
export LANG=en_SG.UTF-8

# BREW RELATED
# Homebrew mirror settings (USTC)
# export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
# export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
# export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
# Disable auto-update for faster operations
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1
