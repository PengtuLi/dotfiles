#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

# 检测是否在 WSL 中
is_wsl() {
    [[ -f /proc/version ]] && grep -qi "microsoft\|wsl" /proc/version
}

# 获取 Windows 用户名
get_windows_username() {
    # 从 WSL 的用户映射中获取 Windows 用户名
    local win_user
    win_user=$(whoami.exe 2>/dev/null | tr -d '\r' | cut -d'\' -f2)
    echo "$win_user"
}

# 复制 VSCode 配置到 Windows
copy_vscode_config_to_windows() {
    local win_user
    win_user=$(get_windows_username)

    if [[ -z "$win_user" ]]; then
        warning "无法获取 Windows 用户名，跳过"
        return 1
    fi

    # Windows 用户目录可能是大写的
    local win_user_dir="/mnt/c/Users/$win_user"
    if [[ ! -d "$win_user_dir" ]]; then
        win_user="${win_user^}"
        win_user_dir="/mnt/c/Users/$win_user"
    fi

    local dotfiles_vscode_user="$ROOT_DIR/stow/gui/vscode/Code/User"
    local win_vscode_user=""

    # 优先检查 scoop 安装的 VSCode
    local scoop_vscode="$win_user_dir/scoop/apps/vscode/current/data/user-data/User"
    if [[ -d "$scoop_vscode" ]]; then
        win_vscode_user="$scoop_vscode"
    # 其次检查标准安装路径
    elif [[ -d "$win_user_dir/AppData/Roaming/Code" ]]; then
        win_vscode_user="$win_user_dir/AppData/Roaming/Code/User"
    fi

    if [[ -z "$win_vscode_user" ]]; then
        warning "未找到 Windows VSCode 配置目录"
        return 1
    fi

    mkdir -p "$win_vscode_user"

    info "复制配置到 Windows VSCode..."

    for config in settings.json keybindings.json tasks.json; do
        if [[ -f "$dotfiles_vscode_user/$config" ]]; then
            cp "$dotfiles_vscode_user/$config" "$win_vscode_user/$config"
            success "已复制: $config"
        fi
    done

    if [[ -d "$dotfiles_vscode_user/snippets" ]]; then
        mkdir -p "$win_vscode_user/snippets"
        cp -r "$dotfiles_vscode_user/snippets/"* "$win_vscode_user/snippets/"
        success "已复制: snippets"
    fi
}

install_vscode_extensions() {
    # List of Extensions
    extensions=(
        ms-python.python
        vscode-icons-team.vscode-icons
        ms-azuretools.vscode-docker
        enkia.tokyo-night
        ms-toolsai.jupyter
        ms-vscode-remote.remote-ssh
    )

    for e in "${extensions[@]}"; do
        info "installing $e"
        code --install-extension "$e" 2>&1 > /dev/null
    done

    success "VSCode extensions installed successfully"
}

# 主逻辑
if is_wsl; then
    info "检测到 WSL 环境"
    copy_vscode_config_to_windows
fi

if command -v code &> /dev/null; then
    install_vscode_extensions
fi
