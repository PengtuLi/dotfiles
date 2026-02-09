#!/usr/bin/env python3
"""
稳健的后台下载脚本 - 支持断点续传和自动重试
永不停止，直到所有文件下载完成
"""

import os
import sys
import time
import json
import signal
import importlib.util
from pathlib import Path
from datetime import datetime

# 配置
MODEL_ID = "facebook/VGGT-1B"
LOCAL_DIR = Path("/data/model/VGGT-1B")
LOG_FILE = Path("/data/model/download_robust.log")
STATE_FILE = Path("/tmp/download_state.json")
MAX_RETRIES = 1000
RETRY_DELAY = 30
CHECK_INTERVAL = 60  # 每60秒检查一次状态

# 全局标志
running = True


def signal_handler(signum, frame):
    global running
    print("\n收到停止信号，正在优雅退出...")
    running = False


signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)


def log(msg, level="INFO"):
    """记录日志"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] [{level}] {msg}"
    print(line)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")
        f.flush()


def get_progress():
    """获取当前下载进度"""
    if not LOCAL_DIR.exists():
        return 0, 0, "0 GB"

    safetensors = list(LOCAL_DIR.rglob("*.safetensors"))
    completed = len(safetensors)

    total_size = sum(f.stat().st_size for f in safetensors if f.is_file())
    total_size_gb = f"{total_size / (1024**3):.2f} GB"

    return completed, total_size, total_size_gb


def save_state(state):
    """保存下载状态"""
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except Exception as e:
        log(f"保存状态失败: {e}", "WARN")


def load_state():
    """加载下载状态"""
    if STATE_FILE.exists():
        try:
            with open(STATE_FILE) as f:
                return json.load(f)
        except Exception:
            pass
    return {"attempts": 0, "last_error": None}


def install_dependencies():
    """确保依赖安装"""
    if importlib.util.find_spec("modelscope") is not None:
        return True
        log("正在安装 modelscope...")
        ret = os.system("pip install modelscope -q")
        if ret == 0:
            log("modelscope 安装成功")
            return True
        else:
            log("modelscope 安装失败", "ERROR")
            return False


def download_model():
    """执行下载"""
    from modelscope import snapshot_download

    log("开始下载模型...")
    log(f"模型ID: {MODEL_ID}")
    log(f"本地目录: {LOCAL_DIR}")

    completed_before, size_before, size_gb_before = get_progress()
    log(f"下载前状态: {completed_before} 个文件, {size_gb_before}")

    try:
        snapshot_download(
            model_id=MODEL_ID,
            cache_dir=str(LOCAL_DIR),
        )

        completed_after, size_after, size_gb_after = get_progress()
        log(f"下载后状态: {completed_after} 个文件, {size_gb_after}")

        if completed_after >= 94:  # 假设总共94个文件
            log("✅ 所有文件下载完成！")
            return True
        else:
            log(f"⚠️ 下载进行中: {completed_after}/94 个文件", "WARN")
            return False

    except Exception as e:
        log(f"❌ 下载异常: {e}", "ERROR")
        import traceback

        log(traceback.format_exc(), "ERROR")
        return False


def main():
    """主函数 - 永不停止的下载循环"""
    log("=" * 60)
    log("稳健下载守护进程启动")
    log("=" * 60)

    # 确保目录存在
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)

    # 安装依赖
    if not install_dependencies():
        log("依赖安装失败，30秒后重试...", "ERROR")
        time.sleep(30)
        return main()

    state = load_state()
    attempt = state.get("attempts", 0)

    while running:
        attempt += 1
        log(f"第 {attempt} 次下载尝试...")

        state["attempts"] = attempt
        save_state(state)

        try:
            success = download_model()

            if success:
                log("🎉 下载任务完成！")
                if STATE_FILE.exists():
                    STATE_FILE.unlink()
                return 0

            # 未完全完成但可能部分成功，继续重试
            completed, _, size_gb = get_progress()
            log(f"当前进度: {completed}/94 个文件, {size_gb}")

        except Exception as e:
            log(f"严重错误: {e}", "ERROR")
            import traceback

            log(traceback.format_exc(), "ERROR")

        if not running:
            break

        log(f"等待 {RETRY_DELAY} 秒后自动重试...")

        # 分段等待以便响应停止信号
        for _ in range(RETRY_DELAY):
            if not running:
                break
            time.sleep(1)

    log("守护进程已停止")
    return 0


if __name__ == "__main__":
    sys.exit(main())
