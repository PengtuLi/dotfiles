# Docker Run 模板

## 全功能 PyTorch（默认）

全部 GPU、IPC host、SSH 端口映射、home + 共享目录挂载：

```bash
docker run -itd \
  --gpus all \
  --ipc host \
  --restart unless-stopped \
  --name <container_name> \
  -p <ssh_port>:22 \
  -v /home/<username>/workspace:/root/workspace \
  -v <share_path>:/share \
  <image>
```

`<container_name>` 格式建议 `<username>_<suffix>`，suffix 按用途命名（如 `train`、`dev`、`exp1`）。

`<share_path>` 按服务器：
- X299AII：`/share`
- WZ6/WZ7：`/data/share`
- 其他服务器：询问用户

## 最小化训练

无 SSH 端口、无共享目录，纯训练：

```bash
docker run -itd \
  --gpus all \
  --ipc host \
  --restart unless-stopped \
  --name <container_name> \
  -v /home/<username>/workspace:/root/workspace \
  <image>
```

## 指定 GPU

```bash
docker run -itd \
  --gpus '"device=0,1"' \
  --ipc host \
  --restart unless-stopped \
  --name <container_name> \
  -p <ssh_port>:22 \
  -v /home/<username>/workspace:/root/workspace \
  -v <share_path>:/share \
  <image>
```
