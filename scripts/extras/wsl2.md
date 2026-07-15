# Windows 环境初始化说明（Scoop + WSL2 + Windows Terminal）
# 本文件为参考脚本/备忘，建议在 PowerShell 7 管理员权限下按需执行对应命令

# 1. 安装 Scoop（需要 PowerShell 7，Win10/11 已自带）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# 1.1 启用 aria2 多线程下载（推荐）
scoop install aria2
scoop config aria2-enabled true
scoop config aria2-split 8
scoop config aria2-max-connection-per-server 8

# 1.2 添加常用 bucket
scoop bucket add main
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts
scoop update

# 2. 安装 Windows 工具
scoop install autohotkey
scoop install clash-verge-rev
scoop install googlechrome
scoop install powertoys
scoop install maple-mono-nf-cn   # Nerd Font 字体(必装)
scoop install spotify
scoop install tencent-meeting
scoop install vscode
scoop install wechat
scoop install openssh

# 3. Windows Terminal 配置复制
源配置文件位于本仓库 stow/gui/windows_terminal/settings.json
复制到 Windows Terminal 用户配置目录(windows_terminal有个打开配置文件的按钮)

# 4. WSL2 与 WSLg 配置
# 4.1 安装 WSL2（默认 Ubuntu，可按需替换）
wsl --install
# 安装完成后重启，按提示设置 archlinux 用户密码

# 4.2 启用 systemd（默认已启用，旧版本需手动配置）
# 在 WSL 内编辑 /etc/wsl.conf，添加：
# [boot]
# systemd=true

# 4.3 启用 GPU 加速（WSLg，Win11 已默认支持）

# 5. AutoHotkey 热键脚本（可选）
# 可将 AHK 脚本放入 %USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
# 实现开机自动加载，例如将仓库中的 ahk 脚本复制到启动目录：
# "$env:USERPROFILE\workspace\dotfiles\scripts\extras\hotkey.ahk" `
# "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\hotkey.ahk" -Force
