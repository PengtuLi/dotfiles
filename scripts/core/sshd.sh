#!/bin/bash
apt update && apt install -y locales nano openssh-server zsh curl git

echo "----change shell"
chsh -s /usr/bin/zsh root

# 生成 en_US.UTF-8 和 zh_CN.UTF-8 语言环境
echo "### 生成 UTF-8 locale 环境..."
touch /etc/locale.gen
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen

echo "export LANG=en_US.UTF-8" >> ~/.zshrc
# echo "export LANGUAGE=en_US:zh_CN" >> ~/.zshrc
# echo "export LC_ALL=en_US.UTF-8" >> ~/.zshrc

ZSHRC="$HOME/.zshrc"

CODE_BLOCK=EOF
source /etc/profile
conda deactivate
conda activate base

EOF

# 检查 ~/.zshrc 是否已存在该代码块
if grep -q "从容器 init 进程导入环境变量" "$ZSHRC" 2>/dev/null; then
    echo "✅ ~/.zshrc 已包含环境变量导入代码，跳过写入。"
else
    echo "📌 正在写入环境变量导入代码到 ~/.zshrc..."

    # 确保文件存在
    touch "$ZSHRC"

    # 在文件末尾添加代码块
    {
        echo ""
        echo "$CODE_BLOCK"
        echo ""
    } >> "$ZSHRC"

    echo "✅ 写入完成！"
fi
####################################
source ~/.zshrc
conda init zsh

# 修改 SSH 配置文件，启用 PermitRootLogin
echo "### 修改 /etc/ssh/sshd_config 中 PermitRootLogin 为 yes..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/' /etc/ssh/sshd_config

# 提示用户设置 root 密码
echo ""
echo "##############################################################################"
echo "⚠️为 root 用户设置密码：1234"
echo 'root:1234' | chpasswd
echo "##############################################################################"

echo "### 正在启动 SSH 服务..."
service ssh start
