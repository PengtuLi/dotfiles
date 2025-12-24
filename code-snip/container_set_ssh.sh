#!/bin/bash
set -e

# 1. 安装 openssh-server（如果尚未安装）
apt-get update
apt-get install -y openssh-server

# 3. 设置 root 密码（这里设为 "root"，你可以改成你想要的）
echo 'root:1234' | chpasswd

# 4. 修改 SSH 配置：允许 root 使用密码登录
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 6. 启动 sshd（前台运行，适合容器）
echo "Starting SSH daemon..."
service ssh start

# gh cli
apt install -y git
(type -p wget >/dev/null || ( apt update &&  apt install wget -y)) \
    &&  mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out |tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    &&  chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    &&  mkdir -p -m 755 /etc/apt/sources.list.d \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |  tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    &&  apt update \
    &&  apt install gh -y

# uv
wget -qO- https://astral.sh/uv/install.sh | sh
echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc
echo 'alias uv-a="source ./.venv/bin/activate"' >> ~/.bashrc
echo 'source /etc/profile' >> ~/.bashrc
# fallback
cat >> ~/.bashrc <<'EOF'
[ -n "$DOCKER_ENV_EXPORTED" ] || {
    export $(cat /proc/1/environ | tr '\0' '\n' | grep -vE '^(HOME|USER|PWD|TERM|SHLVL)=') 2>/dev/null
    export DOCKER_ENV_EXPORTED=1 }
EOF
# 防止 Ctrl+D 退出 shell
echo 'set -o ignoreeof' >> ~/.bashrc
# locale
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
apt install -y locales
locale-gen en_US.UTF-8
locale-gen en_SG.UTF-8
