# Docker Run 模板

## 基础模板

```bash
docker run -itd \
  --gpus all \
  --ipc host \
  --restart unless-stopped \
  --name <container_name> \
  -p <ssh_port>:22 \
  -v /home/<username>/workspace:/root/workspace \
  <image>
```

- `<container_name>` 格式建议 `<username>_<suffix>`，suffix 按用途命名（如 `train`、`dev`、`exp1`）
- 用了 `--ipc host` 时，`--shm-size` 会被忽略

## 额外选项（按需确认）

- `--privileged`：特权模式，容器拥有宿主机所有设备访问权限，调试 GPU 驱动、挂载 FUSE 文件系统、运行需要直接访问硬件的程序时需要
- `--network host`：共享宿主机网络，容器内直接用宿主机端口
- `--shm-size=8g`：共享内存大小，PyTorch DataLoader 常需要调大（与 `--ipc host` 互斥）
- `-e NVIDIA_VISIBLE_DEVICES=0,1`：指定可见 GPU（不指定则 `--gpus all`）

## 服务器预设

要挂载的目录 `<share_path>` 按服务器，以下是确定的特定 HOST 的预设：
- X299AII：`/share`
- WZ6/WZ7：`/data/share`
