import os

os.environ["HF_ENDPOINT"] = "https://hf-mirror.com"  # 设置为镜像站点

from huggingface_hub import login, snapshot_download

login(token="")  # Replace with your actual token
# 1. Download a single file
repo_id = "Qwen/Qwen3-0.6B"
# facebook/opt-13b

local_dir = "/share/models/Qwen3-0.6B"
snapshot_path = snapshot_download(
    repo_id=repo_id, local_dir=local_dir, allow_patterns="*"
)
print(f"\nDownloaded entire repository '{repo_id}' to: {snapshot_path}")
