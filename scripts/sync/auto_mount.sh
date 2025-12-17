#!/bin/bash

set -e

# ======================
# 帮助信息
# ======================
show_help() {
    cat <<EOF
用法: $0 [选项] <ssh_info> <container_name> <mount_point>

参数:
  ssh_info       远程主机的 SSH 地址，例如: user@host
  container_name 远程 Docker 容器名或 ID
  mount_point    本地挂载目录（将被创建如不存在）

选项:
  -h, --help     显示此帮助

示例:
  $0 user@192.168.1.10 my_container /mnt/remote_container
EOF
}

# ======================
# 参数解析
# ======================
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [[ $# -ne 3 ]]; then
    echo "错误：需要 3 个参数" >&2
    show_help
    exit 1
fi

SSH_INFO="$1"
CONTAINER_NAME="$2"
MOUNT_POINT="$3"

# ======================
# 参数校验
# ======================
if [[ -z "$SSH_INFO" || -z "$CONTAINER_NAME" || -z "$MOUNT_POINT" ]]; then
    echo "错误：参数不能为空" >&2
    exit 1
fi

MOUNT_POINT="${MOUNT_POINT%/}"  # 去除末尾斜杠

if [[ ! -d "$MOUNT_POINT" ]]; then
    echo "挂载点 $MOUNT_POINT 不存在，尝试创建..."
    mkdir -p "$MOUNT_POINT"
    chmod 755 "$MOUNT_POINT"
fi

# ======================
# 获取远程容器的 bind mounts
# ======================
echo "正在通过 SSH 查询容器 $CONTAINER_NAME 的 bind mounts..."

# 构造 docker inspect 命令，只输出 bind mounts 的 Source 和 Destination
# 格式：/host/path:/container/path
MOUNTS_RAW=$(ssh "$SSH_INFO" "docker inspect -f '{{range \$m := .Mounts}}{{if eq \$m.Type \"bind\"}}{{\$m.Source}}:{{\$m.Destination}}{{println}}{{end}}{{end}}' '$CONTAINER_NAME'")

if [[ -z "$MOUNTS_RAW" ]]; then
    echo "⚠️ 未找到任何 bind mounts（可能只有 volumes 或容器不存在）"
    exit 1
fi

echo "检测到以下 bind mounts："
echo "$MOUNTS_RAW"

# ======================
# 挂载每个路径
# ======================
# 转换为数组（按行分割）
mapfile -t MOUNT_PAIRS <<< "$MOUNTS_RAW"

echo "开始挂载到本地子目录..."

for pair in "${MOUNT_PAIRS[@]}"; do
    if [[ -z "$pair" ]]; then
        continue
    fi

    # 拆分 Source 和 Destination
    IFS=':' read -r REMOTE_SOURCE REMOTE_DEST <<< "$pair"

    # 为容器内路径生成本地子目录名（避免 / 开头，用 basename 或替换 / 为 _）
    # 简单做法：取最后一段（如 /workspace/pcb_vlm → pcb_vlm）
    SUBDIR_NAME=$(basename "$REMOTE_DEST")

    # 如果多个 mount 有相同 basename，可考虑用完整路径哈希，但先用 basename
    LOCAL_SUBDIR="$MOUNT_POINT/$SUBDIR_NAME"

    # 如果子目录已存在但非空，跳过或报错（保守起见：跳过）
    if [[ -e "$LOCAL_SUBDIR" ]]; then
        if [[ -d "$LOCAL_SUBDIR" && -n "$(ls -A "$LOCAL_SUBDIR" 2>/dev/null)" ]]; then
            echo "⚠️ 跳过 $REMOTE_SOURCE → $LOCAL_SUBDIR（非空）"
            continue
        fi
    else
        mkdir -p "$LOCAL_SUBDIR"
    fi

    echo "挂载 $SSH_INFO:$REMOTE_SOURCE → $LOCAL_SUBDIR"

    sshfs "$SSH_INFO:$REMOTE_SOURCE" "$LOCAL_SUBDIR" \
        -o default_permissions \
        -o uid=$(id -u) \
        -o gid=$(id -g) \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=3

    echo "✅ 挂载成功: $LOCAL_SUBDIR"
done

echo ""
echo "📌 挂载完成！所有子目录位于: $MOUNT_POINT"
echo "💡 使用完毕后，请依次卸载："
for pair in "${MOUNT_PAIRS[@]}"; do
    [[ -z "$pair" ]] && continue
    REMOTE_DEST=$(cut -d':' -f2 <<< "$pair")
    SUBDIR_NAME=$(basename "$REMOTE_DEST")
    LOCAL_SUBDIR="$MOUNT_POINT/$SUBDIR_NAME"
    echo "  sudo umount '$LOCAL_SUBDIR'"
done
