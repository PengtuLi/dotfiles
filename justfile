# Justfile - dotfiles 安装管理
# 使用方式: just <preset> 或 just <component>

set dotenv-load := false

# 获取脚本根目录
ROOT_DIR := justfile_directory()
SCRIPTS_DIR := ROOT_DIR + "/scripts"
BREWFILE_DIR := ROOT_DIR + "/brewfile"

# 显示可用命令 (分组显示)
default:
    @echo "可用预设 (完整安装流程):"
    @echo "  osx              - macOS 完整配置"
    @echo "  linux-gui        - Linux GUI 配置"
    @echo "  linux-headless   - Linux 无头配置"
    @echo "  ssh              - Linux ssh配置"
    @echo ""
    @echo "可用组件 (单独安装):"
    @echo "  proxy            - 代理配置"
    @echo "  conda            - Conda 环境设置"
    @echo "  vscode           - vscode 插件安装"
    @echo "  prerequisites-osx - 前置依赖 (macOS)"
    @echo "  prerequisites-linux - 前置依赖 (Linux)"
    @echo "  stow-osx         - dotfiles 链接 (macOS)"
    @echo "  stow-linux       - dotfiles 链接 (Linux)"
    @echo "  shell_scripts    - Shell 脚本设置"
    @echo "  extras-osx       - 额外配置 (macOS)"
    @echo "  extras-linux     - 额外配置 (Linux)"
    @echo "  mesh             - Mesh 设置"
    @echo ""
    @echo "远程部署:"
    @echo "  ssh-proxy <host> - 推送 mihomo 到远程服务器"
    @echo ""
    @echo "Brew 包组:"
    @echo "  brew-osx              - macOS 包组 (basic + doc + font + remote + osx)"
    @echo "  brew-linux-gui        - Linux GUI 包组 (basic + doc + font + remote)"
    @echo "  brew-linux-headless   - Linux 无头包组 (basic + remote)"
    @echo ""
    @echo "其他:"
    @echo "  list             - 分组显示所有命令"
    @echo "  just --list      - 按字母顺序显示所有命令"

# 分组显示所有命令
list: default

# ============================================================================
# 预设 (完整安装流程)
# ============================================================================

# macOS 完整配置
osx: prerequisites-osx stow-osx shell_scripts extras-osx brew-osx vscode

# Linux GUI 配置
linux-gui: prerequisites-linux stow-linux shell_scripts extras-linux brew-linux-gui vscode

# Linux 无头配置
linux-headless: prerequisites-linux stow-linux shell_scripts brew-linux-headless

ssh: _ssh_linux
# ============================================================================
# 组件 (单独安装)
# ============================================================================

# 代理配置
proxy:
    @echo "🔧 设置代理..."
    @bash "{{SCRIPTS_DIR}}/core/proxy.sh"

# Conda 环境设置
conda:
    @echo "🐍 设置 Conda..."
    @bash "{{SCRIPTS_DIR}}/core/conda.sh"

# vscode setting
vscode:
    @echo "📦 设置 vscode..."
    @bash "{{SCRIPTS_DIR}}/extras/vscode-extensions.sh"


# 前置依赖 (macOS)
prerequisites-osx:
    @echo "📦 安装前置依赖 (osx)..."
    @bash "{{SCRIPTS_DIR}}/core/prerequisites.sh" osx

# 前置依赖 (Linux)
prerequisites-linux:
    @echo "📦 安装前置依赖 (linux)..."
    @bash "{{SCRIPTS_DIR}}/core/prerequisites.sh" linux

# Stow dotfiles 链接 (macOS)
stow-osx:
    @echo "🔗 链接 dotfiles (osx)..."
    @bash "{{SCRIPTS_DIR}}/core/stow.sh" osx

# Stow dotfiles 链接 (Linux)
stow-linux:
    @echo "🔗 链接 dotfiles (linux)..."
    @bash "{{SCRIPTS_DIR}}/core/stow.sh" linux

# Shell 脚本设置
shell_scripts:
    @echo "📜 设置 Shell 脚本..."
    @bash "{{SCRIPTS_DIR}}/core/shell-scripts.sh"

# 额外配置 (macOS)
extras-osx:
    @if [[ ! -f "{{SCRIPTS_DIR}}/extras/osx.sh" ]]; then echo "⚠️  脚本不存在: {{SCRIPTS_DIR}}/extras/osx.sh"; exit 0; fi
    @echo "⚙️  安装额外配置 (osx)..."
    @bash "{{SCRIPTS_DIR}}/extras/osx.sh"

# 额外配置 (Linux)
extras-linux:
    @if [[ ! -f "{{SCRIPTS_DIR}}/extras/linux.sh" ]]; then echo "⚠️  脚本不存在: {{SCRIPTS_DIR}}/extras/linux.sh"; exit 0; fi
    @echo "⚙️  安装额外配置 (linux)..."
    @bash "{{SCRIPTS_DIR}}/extras/linux.sh"

# Mesh 设置
mesh:
    @echo "🌐 设置 Mesh..."
    @bash "{{SCRIPTS_DIR}}/core/mesh.sh"

# ============================================================================
# SSH Proxy
# ============================================================================

# 推送 mihomo 代理文件到远程服务器
ssh-proxy host='':
    @echo "📦 推送 mihomo 代理文件到 {{host}}..."
    @ssh {{host}} "mkdir -p ~/mihomo-setup/mihomo-clash ~/mihomo-setup/scripts/core ~/mihomo-setup/scripts/lib"
    @# 获取远程架构并推送对应二进制
    @arch=$(ssh {{host}} "uname -m") && \
    case "$arch" in \
      x86_64)  binary="mihomo-linux-amd64" ;; \
      aarch64) binary="mihomo-linux-arm64" ;; \
      *)       echo "❌ 不支持的架构: $arch"; exit 1 ;; \
    esac && \
    echo "  📤 检测远程架构: $arch，推送 $binary..." && \
    rsync -azP {{ROOT_DIR}}/mihomo-clash/"$binary" {{host}}:~/mihomo-setup/mihomo-clash/
    @echo "  📤 推送配置文件..."
    @rsync -azP {{ROOT_DIR}}/mihomo-clash/config/ {{host}}:~/mihomo-setup/mihomo-clash/config/
    @echo "  📤 推送安装脚本..."
    @rsync -azP {{ROOT_DIR}}/scripts/core/proxy.sh {{host}}:~/mihomo-setup/scripts/core/
    @rsync -azP {{ROOT_DIR}}/scripts/lib/common.sh {{host}}:~/mihomo-setup/scripts/lib/
    @echo ""
    @echo "✅ 推送完成，请执行以下命令安装:"
    @echo "   ssh {{host}}"
    @echo "   bash ~/mihomo-setup/scripts/core/proxy.sh"

# ============================================================================
# _ssh_linux
# ============================================================================

_ssh_linux:
    @if [[ ! -f "{{SCRIPTS_DIR}}/ssh/brew_sync.py" ]]; then echo "❌ 错误: {{SCRIPTS_DIR}}/ssh/brew_sync 不存在"; exit 1; fi
    @echo "📦 ssh setup..."
    @source ".venv/bin/activate" && python "{{SCRIPTS_DIR}}/ssh/brew_sync.py"

# ============================================================================
# Brew 包组 (公开命令)
# ============================================================================

# macOS 包组
brew-osx: _brew-basic _brew-doc _brew-font _brew-remote _brew-osx

# Linux GUI 包组
brew-linux-gui: _brew-basic _brew-doc _brew-font _brew-remote

# Linux 无头包组
brew-linux-headless: _brew-basic _brew-remote

# ============================================================================
# 单个 Brewfile (私有组件，用 _ 前缀隐藏)
# ============================================================================

# 基础包
_brew-basic:
    @if [[ ! -f "{{BREWFILE_DIR}}/Brewfile.basic" ]]; then echo "❌ 错误: {{BREWFILE_DIR}}/Brewfile.basic 不存在"; exit 1; fi
    @echo "📦 安装基础包..."
    @brew bundle --force --file "{{BREWFILE_DIR}}/Brewfile.basic"

# 文档工具
_brew-doc:
    @if [[ ! -f "{{BREWFILE_DIR}}/Brewfile.doc" ]]; then echo "❌ 错误: {{BREWFILE_DIR}}/Brewfile.doc 不存在"; exit 1; fi
    @echo "📦 安装文档工具..."
    @brew bundle --force --file "{{BREWFILE_DIR}}/Brewfile.doc"

# 字体
_brew-font:
    @if [[ ! -f "{{BREWFILE_DIR}}/Brewfile.font" ]]; then echo "❌ 错误: {{BREWFILE_DIR}}/Brewfile.font 不存在"; exit 1; fi
    @echo "📦 安装字体..."
    @brew bundle --force --file "{{BREWFILE_DIR}}/Brewfile.font"

# macOS 特定包
_brew-osx:
    @if [[ ! -f "{{BREWFILE_DIR}}/Brewfile.osx" ]]; then echo "❌ 错误: {{BREWFILE_DIR}}/Brewfile.osx 不存在"; exit 1; fi
    @echo "📦 安装 macOS 特定包..."
    @brew bundle --force --file "{{BREWFILE_DIR}}/Brewfile.osx"

# 远程同步工具
_brew-remote:
    @if [[ ! -f "{{BREWFILE_DIR}}/Brewfile.remote" ]]; then echo "❌ 错误: {{BREWFILE_DIR}}/Brewfile.remote 不存在"; exit 1; fi
    @echo "📦 安装远程同步工具..."
    @brew bundle --force --file "{{BREWFILE_DIR}}/Brewfile.remote"
