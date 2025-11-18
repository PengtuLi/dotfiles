import os
import argparse
from huggingface_hub import snapshot_download


def main():
    parser = argparse.ArgumentParser(
        description="使用 HF-Mirror 镜像下载 Hugging Face 模型或数据集"
    )
    parser.add_argument(
        "--repo_id",
        type=str,
        required=True,
        help="Hugging Face 仓库 ID，例如 'mandarjoshi/trivia_qa'",
    )
    parser.add_argument(
        "--repo_type",
        type=str,
        default="model",
        choices=["model", "dataset", "space"],
        help="仓库类型，默认为 'model'",
    )
    parser.add_argument("--local_dir", type=str, required=True, help="本地保存路径")
    parser.add_argument(
        "--allow_patterns",
        type=str,
        default=None,
        help="允许下载的文件模式（如 '*.json', '*.parquet'），多个用逗号分隔，留空则下载全部",
    )
    parser.add_argument(
        "--hf_token",
        type=str,
        default=None,
        help="Hugging Face Access Token（如需下载私有或 gated 仓库）",
    )
    parser.add_argument("--max_workers", type=int, default=8, help="下载线程数，默认 8")
    parser.add_argument(
        "--resume_download", action="store_true", help="启用断点续传（默认开启）"
    )

    args = parser.parse_args()

    # 设置镜像端点（注意：你原来代码中有多余空格！）
    os.environ["HF_ENDPOINT"] = "https://hf-mirror.com"
    if args.hf_token:
        os.environ["HF_TOKEN"] = args.hf_token

    # 处理 allow_patterns（如果提供）
    allow_patterns = args.allow_patterns.split(",") if args.allow_patterns else None

    print(f"准备下载 {args.repo_type}: {args.repo_id}")
    print(f"保存到路径: {args.local_dir}")
    if allow_patterns:
        print(f"仅下载匹配模式: {allow_patterns}")

    # 开始下载
    snapshot_download(
        repo_id=args.repo_id,
        repo_type=args.repo_type,
        local_dir=args.local_dir,
        # depreciate
        # resume_download=args.resume_download or True,
        max_workers=args.max_workers,
        allow_patterns=allow_patterns,
    )

    print(f"✅ 下载完成！路径: {args.local_dir}")


if __name__ == "__main__":
    main()
