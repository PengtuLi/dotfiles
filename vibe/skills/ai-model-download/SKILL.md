---
name: ai-model-download
description: AI 模型下载与管理工具。支持从 HuggingFace 和 ModelScope 下载/上传模型与数据集，包括批量下载、断点续传、完整性校验、参数量统计、代理配置、网络诊断。当用户需要下载模型、上传模型、管理模型缓存、校验模型完整性、挂载远程仓库、管理 HF 云存储时触发。
allowed-tools: Bash, Read, Write
---

# AI 模型下载与管理

统一管理 HuggingFace 和 ModelScope 两个平台的模型下载、上传、校验等操作。

---

## 快速参考

| 任务 | 平台 | 命令 |
|------|------|------|
| 登录 | HF | `hf auth login` |
| 登录 | HF | `hf auth login --token $HF_TOKEN` |
| 下载模型 | HF | `hf download <repo_id>` |
| 下载到目录 | HF | `hf download <repo_id> --local-dir ./path` |
| 下载特定文件 | HF | `hf download <repo_id> file.safetensors` |
| 过滤下载 | HF | `hf download <repo_id> --include "*.safetensors"` |
| 下载数据集 | HF | `hf download <repo_id> --repo-type dataset` |
| 上传文件 | HF | `hf upload <repo_id> ./path .` |
| 创建仓库 | HF | `hf repo create <name>` |
| 查看缓存 | HF | `hf cache ls` |
| 清理缓存 | HF | `hf cache prune` |
| 安装 | MS | `pip install modelscope` |
| 下载模型 | MS | `modelscope download --model 'org/model'` |
| 下载到目录 | MS | `modelscope download --model 'org/model' --local_dir ./path` |
| 排除文件 | MS | `modelscope download --model 'org/model' --exclude '*.onnx'` |
| 下载数据集 | MS | `modelscope download --dataset 'org/dataset'` |
| 搜索模型 | MS | `modelscope search --model 'qwen'` |

---

## 一、HuggingFace

### 认证

```bash
hf auth login                              # 交互式登录
hf auth login --token $HF_TOKEN            # 非交互式
hf auth whoami                             # 查看当前用户
hf auth logout                             # 登出
```

### 下载

```bash
# 基础下载（使用缓存）
hf download meta-llama/Llama-3.2-1B-Instruct

# 下载到指定目录
hf download meta-llama/Llama-3.2-1B-Instruct --local-dir ./models

# 只下载特定文件
hf download meta-llama/Llama-3.2-1B-Instruct config.json tokenizer.json

# 按模式过滤
hf download meta-llama/Llama-3.2-1B-Instruct --include "*.safetensors" --exclude "*.bin"

# 指定版本/分支
hf download stabilityai/stable-diffusion-xl-base-1.0 --revision fp16

# 下载数据集
hf download HuggingFaceH4/ultrachat_200k --repo-type dataset

# 下载 Space
hf download HuggingFaceH4/zephyr-chat --repo-type space

# 静默模式（脚本中使用）
MODEL_PATH=$(hf download gpt2 --quiet)
```

**下载选项：**

| 选项 | 说明 |
|------|------|
| `--repo-type` | `model`（默认）、`dataset`、`space` |
| `--revision` | 分支、标签或 commit hash |
| `--include` | 包含文件模式 |
| `--exclude` | 排除文件模式 |
| `--local-dir` | 下载到指定目录（不使用缓存） |
| `--cache-dir` | 自定义缓存目录 |
| `--force-download` | 强制重新下载 |
| `--max-workers` | 并发下载线程数 |
| `--token` | 认证 token |
| `--quiet` | 静默模式 |

### 上传

```bash
# 上传当前目录
hf upload my-username/my-model . .

# 上传到指定路径
hf upload my-username/my-model ./models /weights

# 上传单个文件
hf upload my-username/my-model model.safetensors

# 上传数据集
hf upload my-username/my-dataset ./data . --repo-type dataset

# 创建 PR
hf upload community/shared-dataset ./data /data --repo-type dataset --create-pr

# 同步（删除远程多余文件）
hf upload my-username/my-app . . --repo-type space --exclude="/logs/*" --delete="*"

# 大文件夹上传（多线程，支持中断续传）
hf upload-large-folder <repo_id> <local_folder> [path_in_repo] --num-workers 8
```

### 仓库管理

```bash
# 创建
hf repo create my-model --private
hf repo create my-dataset --repo-type dataset
hf repo create my-space --repo-type space --space_sdk gradio

# 删除
hf repo delete my-username/my-model

# 标签
hf repo tag create my-username/my-model v1.0
hf repo tag list my-username/my-model

# 分支
hf repo branch create my-username/my-model release-v1
```

### 缓存管理

```bash
hf cache ls                           # 查看缓存
hf cache ls --filter "size>1GB"       # 过滤大文件
hf cache rm model/gpt2                # 删除指定缓存
hf cache prune                        # 清理孤立版本
hf cache verify gpt2                  # 校验校验和
```

**环境变量：**

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `HF_TOKEN` | 认证 token | - |
| `HF_HUB_CACHE` | 缓存目录 | `~/.cache/huggingface/hub` |
| `HF_HUB_DOWNLOAD_TIMEOUT` | 下载超时（秒） | 10 |
| `HF_HUB_OFFLINE` | 离线模式 | False |

### 浏览 Hub

```bash
# 模型
hf models ls --filter "text-generation" --sort downloads --limit 10
hf models ls --search "MiniMax" --author MiniMaxAI
hf models info meta-llama/Llama-3.2-1B-Instruct

# 数据集
hf datasets ls --sort downloads --limit 10
hf datasets ls --search "finepdfs"
```

### 仓库挂载（hf-mount）

无需下载，按需读取远程仓库文件：

```bash
# 安装
curl -fsSL https://raw.githubusercontent.com/huggingface/hf-mount/main/install.sh | sh

# 挂载仓库（只读）
hf-mount start repo openai-community/gpt2 /tmp/gpt2

# 挂载云存储桶（读写）
hf-mount start --hf-token $HF_TOKEN bucket myuser/my-bucket /tmp/data

# 管理
hf-mount status
hf-mount stop /tmp/gpt2
```

### 数据集高级操作

```bash
# SQL 查询数据集（DuckDB）
hf datasets sql "SELECT * FROM 'HuggingFaceFW/fineweb' LIMIT 10"

# 数据集排行榜（找最佳模型）
hf datasets leaderboard HuggingFaceH4/MMLU

# 查看 Parquet 文件
hf datasets parquet HuggingFaceH4/ultrachat_200k

# 模型卡片
hf models card meta-llama/Llama-3.2-1B-Instruct
hf datasets card HuggingFaceFW/fineweb

# 按参数量过滤模型
hf models list --num-parameters ">7B" --sort downloads
```

### Space 高级管理

```bash
# 配置
hf spaces secrets add my-space --secrets API_KEY=xxx
hf spaces variables add my-space --env DEBUG=true
hf spaces volumes set my-space --volume /data=/tmp/data
hf spaces settings my-space --hardware a10g-small --sleep-time 30

# 开发
hf spaces dev-mode my-space                    # 开发模式
hf spaces hot-reload my-space --local-file app.py  # 热重载
hf spaces logs my-space --follow               # 运行日志
hf spaces restart my-space                     # 重启
```

### 仓库复制与设置

```bash
# 复制仓库
hf repos duplicate meta-llama/Llama-3.2-1B-Instruct --private

# 仓库设置
hf repos settings my-repo --private true       # 设为私有
hf repos settings my-repo --gated auto         # 设为门控

# 删除文件
hf repos delete-files my-repo "*.bin" "folder/old_file.pt"
```

### 集合（Collections）

```bash
hf collections create "My Models" --description "Best models"
hf collections add-item my-slug meta-llama/Llama-3.2-1B-Instruct model
hf collections list --owner my-username
```

### CLI 扩展

```bash
hf extensions search                            # 搜索扩展
hf extensions install user/extension-repo       # 安装
hf extensions list                              # 已安装
```

---

## 二、ModelScope

### 前置条件

```bash
# 安装（推荐清华镜像）
pip install modelscope -i https://pypi.tuna.tsinghua.edu.cn/simple
```

### CLI 下载

```bash
# 下载模型
modelscope download --model 'Qwen/Qwen3.5-2B-Base'

# 下载到指定目录
modelscope download --model 'Qwen/Qwen3.5-2B-Base' --local_dir ./models

# 下载特定版本
modelscope download --model 'Qwen/Qwen3.5-2B-Base' --revision v1.0.0

# 包含/排除文件
modelscope download --model 'Qwen/Qwen3.5-2B-Base' --include '*.safetensors'
modelscope download --model 'Qwen/Qwen3.5-2B-Base' --exclude '*.onnx,*.onnx_data'

# 下载数据集
modelscope download --dataset 'WorldVQA/WorldVQA' --local_dir ./datasets

# 搜索
modelscope search --model 'qwen'
```

### Python SDK

```python
from modelscope import snapshot_download

# 下载模型
model_dir = snapshot_download('Qwen/Qwen3.5-2B-Base')

# 下载到指定目录
model_dir = snapshot_download('Qwen/Qwen3.5-2B-Base', cache_dir='/path/to/cache')

# 下载数据集
dataset_dir = snapshot_download('PAI/OmniThought', dataset=True)

# 文件过滤
model_dir = snapshot_download(
    'Qwen/Qwen3.5-2B-Base',
    allow_patterns=['*.safetensors', 'config.json'],
    ignore_patterns=['*.onnx', '*.onnx_data']
)
```

### 批量下载脚本

使用内置脚本进行批量下载：

```bash
# 编辑模型列表后执行
bash scripts/run_ms_model_download.sh

# 批量下载数据集
bash scripts/run_ms_datasets_download.sh

# 网络不稳定时循环重试
bash scripts/ms_loop.sh scripts/run_ms_model_download.sh
bash scripts/ms_loop.sh scripts/run_ms_model_download.sh 10  # 10秒间隔
```

在 `run_ms_model_download.sh` 中配置：

```bash
MODELS=(
  Qwen/Qwen3.5-2B-Base
  Eco-Tech/Qwen3.5-397B-A17B-w8a8-mtp
)
DIR="./models"
EXCLUDE="*.onnx *.onnx_data"
```

### 下载优化

```bash
# 增加下载线程
export MODELSCOPE_DOWNLOAD_THREAD_NUM=8

# 设置缓存目录
export MODELSCOPE_CACHE=/path/to/cache
```

### 环境检查与诊断

```bash
# 前置环境检查
bash scripts/run_preflight_check.sh

# 网络诊断
bash scripts/run_network_diagnose.sh

# 代理配置（交互式）
bash scripts/setup_proxy.sh

# 手动设置代理
export HTTP_PROXY=http://proxy-host:port
export HTTPS_PROXY=http://proxy-host:port
```

### 完整性校验

```bash
# 校验模型
bash scripts/run_check_sha.sh ./models/Qwen-2B
```

### 参数量统计

```bash
# 统计单个模型
bash scripts/run_report_param.sh ./models/Qwen-2B

# 统计目录下所有模型
bash scripts/run_report_param.sh ./models
```

**输出示例：**
```
模型: Qwen-2B
========================================
权重文件数量: 2
模型总大小: 4.00 GB
数据精度: BF16/FP16 (每参数 2.0 字节)
推测参数量: 2.00 B (1-7B)
```

**精度对照：**

| 精度 | 字节/参数 | 文件标识 |
|-----|----------|---------|
| FP32 | 4.0 | `*FP32*` |
| BF16/FP16 | 2.0 | `*BF16*`、`*FP16*` |
| W8A8Z/W8A8 | 1.0 | `*W8A8*` |
| W4A8/Q4 | 0.5 | `*W4A8*`、`*Q4*` |

## 三、HuggingFace Python 上传（高级）

基于 `huggingface_hub` 的上传操作，支持指数退避重试：

### 配置

环境变量：
- `HUGGING_FACE_USERNAME` - HF 用户名
- `HUGGING_FACE_TOKEN` - HF token
- `HUGGING_FACE_REPO` - 模型仓库名
- `HUGGING_FACE_DATASET_PATH` - 数据集路径

### Python 上传示例

```python
import asyncio
from pathlib import Path

# 使用 hf_upload 模块（见 scripts/hf_upload.py）
from hf_upload import upload_file, upload_folder, append_to_jsonl

# 上传单个文件
result = await upload_file(Path("my_file.md"), "lineage/my_file.md")

# 上传文件夹
result = await upload_folder(Path("./output"), "models/")

# 追加 JSONL 记录
result = await append_to_jsonl([{"type": "learning", "content": "..."}])
```

所有上传操作包含指数退避重试（最多 5 次），返回 `HFUploadResult`（`success`、`repo_url`、`remote_path`、`error`）。

---

## 四、常见问题

### SSL 证书验证失败

```bash
# 方法 1：安装 CA 证书（推荐）
# CentOS/RHEL:
sudo cp your-ca.crt /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust
# Ubuntu/Debian:
sudo cp your-ca.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates

# 方法 2：禁用验证
export PYTHONSSLVERIFY=0
```

### 下载中断

```bash
# HF：直接重新执行（缓存机制自动处理）
hf download <repo_id>

# MS：使用循环重试
bash scripts/ms_loop.sh scripts/run_ms_model_download.sh
```

### 磁盘空间不足

```bash
# HF 清理缓存
hf cache prune

# MS 清理缓存
rm -rf ~/.cache/modelscope/hub/
```

### 模型 ID 找不到

- HuggingFace：访问 https://huggingface.co/models 搜索
- ModelScope：访问 https://modelscope.cn/models 搜索
- 确认格式：`组织/模型名`，注意大小写

---

## 五、脚本参考

| 脚本 | 功能 | 用法 |
|-----|------|------|
| `scripts/run_ms_model_download.sh` | MS 批量下载模型 | 编辑模型列表后执行 |
| `scripts/run_ms_datasets_download.sh` | MS 批量下载数据集 | 编辑数据集列表后执行 |
| `scripts/ms_loop.sh` | 循环重试 | `bash scripts/ms_loop.sh <脚本> [间隔]` |
| `scripts/run_check_sha.sh` | SHA256 校验 | `bash scripts/run_check_sha.sh <目录>` |
| `scripts/run_report_param.sh` | 参数量统计 | `bash scripts/run_report_param.sh <目录>` |
| `scripts/run_preflight_check.sh` | 环境检查 | `bash scripts/run_preflight_check.sh` |
| `scripts/run_network_diagnose.sh` | 网络诊断 | `bash scripts/run_network_diagnose.sh` |
| `scripts/setup_proxy.sh` | 代理配置 | `bash scripts/setup_proxy.sh` |
| `scripts/hf_upload.py` | HF Python 上传 | Python 导入使用 |
| `scripts/hf_config.py` | HF 配置验证 | `python scripts/hf_config.py` |
