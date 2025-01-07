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
# --- Pytorch/CUDA Docker Image Environment Loader ---
# This script loads essential environment variables from the container's main process (PID 1)
# into the current SSH session. This ensures that tools like conda, nvcc, and python work correctly.

# Define a list of variable prefixes we want to import.
# Using a '|' separated string for grep's ERE mode.
VARS_TO_LOAD="^PATH=|^LD_LIBRARY_PATH=|^CONDA_|^CUDA_|^CUDNN_|^NVIDIA_"

# Read the environment from PID 1, convert null separators to newlines,
# filter for the variables we want, and then loop through and export them.
for item in $(cat /proc/1/environ | tr '\0' '\n' | /bin/grep -E "$VARS_TO_LOAD")
do
  # Using quotes "$item" is a robust way to handle values that might contain spaces.
  export "$item"
done

# Optional: Unset the temporary variable for a cleaner environment
unset VARS_TO_LOAD

# --- End of Loader ---
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
