#!/bin/bash

# 固定参数部分
# pytorch/pytorch:2.6.0-cuda12.6-cudnn9-devel
IMAGE="pytorch/pytorch:2.6.0-cuda12.6-cudnn9-devel"
WORKSPACE_VOL="/home/lpt:/root/host"
SHARE_VOL="/share:/share"
DEFAULT_SHELL="/bin/zsh"
CPU_PROFILER="--privileged"
GPU="--gpus all"
IPC="--ipc host"

# 提示用户输入容器名称
read -p "请输入容器名称 (默认: lpt): " CONTAINER_NAME
CONTAINER_NAME=${CONTAINER_NAME:-lpt}

# 提示用户输入 SSH 端口映射
read -p "请输入主机SSH端口 (默认: 16660:22): " PORT_MAP
PORT_MAP=${PORT_MAP:-16660:22}

# 构建最终命令
CMD="docker run -itd \
  --name $CONTAINER_NAME \
  -p $PORT_MAP \
  -v $WORKSPACE_VOL \
  -v $SHARE_VOL \
  $GPU \
  $IPC \
  $CPU_PROFILER \
  $IMAGE \
  /bin/bash \
  "

# 打印并运行命令
echo -e "\n即将运行以下命令：\n"
echo "$CMD"
echo ""

eval $CMD

echo -e "\n✅ 容器已启动！容器名: $CONTAINER_NAME"

echo "run init container"

docker exec $CONTAINER_NAME /bin/bash /root/host/dotfiles/code-snip/ssh-install.sh
