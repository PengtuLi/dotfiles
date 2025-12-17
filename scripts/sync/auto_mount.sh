#!/bin/bash

set -e

# ======================
# 配置参数（可按需修改）
# ======================
SSH_USER="your_username"       # 远程 SSH 用户名
SSH_HOST="remote.example.com" # 远程主机地址
CONTAINER_NAME="my_container" # Docker 容器名或 ID
MOUNT_POINT="/mnt/docker-fs"  # 本地挂载点（需提前存在或脚本自动创建）

# ======================
# 参数校验
# ======================
if [[ -z "$SSH_USER" || -z "$SSH_HOST" || -z "$CONTAINER_NAME" ]]; then
    echo "错误：请在脚本中设置 SSH_USER、SSH_HOST 和 CONTAINER_NAME！"
    exit 1
fi

if [[ ! -d "$MOUNT_POINT" ]]; then
    echo "挂载点 $MOUNT_POINT 不存在，尝试创建..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# ======================
# 获取远程容器的文件系统路径
# ======================
echo "正在通过 SSH 查询容器 $CONTAINER_NAME 的文件系统路径..."

# 尝试获取容器的 GraphDriver 数据（适用于 overlay2、aufs 等）
REMOTE_FS_PATH=$(ssh "$SSH_USER@$SSH_HOST" "
    set -e
    CONTAINER_ID=\$(docker inspect -f '{{.Id}}' '$CONTAINER_NAME')
    if [ -z \"\$CONTAINER_ID\" ]; then
        echo '容器不存在' >&2
        exit 1
    fi
    docker inspect -f '{{.GraphDriver.Data.MergedDir}}' \"\$CONTAINER_ID\" 2>/dev/null || \
    docker inspect -f '{{.GraphDriver.Data.UpperDir}}' \"\$CONTAINER_ID\" 2>/dev/null || \
    echo '无法获取容器文件系统路径，请确认 Docker 存储驱动（如 overlay2）是否支持'
")

if [[ "$REMOTE_FS_PATH" == *"无法获取"* || -z "$REMOTE_FS_PATH" ]]; then
    echo "错误：$REMOTE_FS_PATH"
    exit 1
fi

echo "远程容器文件系统路径: $REMOTE_FS_PATH"

# ======================
# 挂载
# ======================
echo "正在挂载 $SSH_USER@$SSH_HOST:$REMOTE_FS_PATH 到 $MOUNT_POINT ..."
sshfs "$SSH_USER@$SSH_HOST:$REMOTE_FS_PATH" "$MOUNT_POINT" -o allow_other,default_permissions,reconnect

echo "✅ 挂载成功！本地路径：$MOUNT_POINT"
echo "📌 使用完后请运行：sudo umount $MOUNT_POINT"
