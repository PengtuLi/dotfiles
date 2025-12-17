#!/bin/bash

# ================== 配置区 ==================
LOG_FILE="$PWD/sync-auto.log"

if [ $# -lt 1 ]; then
    echo -e "\033[31m❌ 用法: $0 <远程主机名> [本地目录] [远程目录]\033[0m"
    echo "   本地目录默认: $DEFAULT_LOCAL_DIR"
    echo "   远程目录默认: $DEFAULT_REMOTE_DIR"
    exit 1
fi

REMOTE_HOSTNAME="$1"
LOCAL_DIR="${2}"
REMOTE_DIR="${3}"

# Rsync 排除列表 (数组格式，更安全)
EXCLUDES=(
    "--exclude=.git/"
    "--exclude=node_modules/"
    "--exclude=__pycache__/"
    "--exclude=.DS_Store"
    "--exclude=*.swp"
    "--exclude=.vscode/"
)

if [ $# -lt 1 ]; then
    echo -e "\033[31m❌ 用法: $0 <远程主机名> [本地目录] [远程目录]\033[0m"
    echo "   示例: $0 user@server /home/user/project /remote/project"
    exit 1
fi

# Rsync 常用选项
# -a: 归档模式
# -z: 压缩传输
# --delete: 删除远程有多余的文件
# -no- --no-owner --no-group: 忽略权限/用户组差异（避免权限不足报错）
RSYNC_OPTS=(-avz --delete --no-owner --no-group)

# ================== 功能函数 ==================

# 统一日志函数：终端带颜色，文件不带颜色
log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color_start=""
    local color_end="\033[0m"

    case "$level" in
        INFO)    color_start="\033[36m" ;; # 青色
        SUCCESS) color_start="\033[32m" ;; # 绿色
        WARN)    color_start="\033[33m" ;; # 黄色
        ERROR)   color_start="\033[31m" ;; # 红色
    esac

    # 1. 输出到终端 (带颜色)
    echo -e "${color_start}[${timestamp}] [${level}] ${msg}${color_end}"

    # 2. 输出到日志文件 (去除颜色代码)
    # 如果不想用 sed 去除颜色，可以手动分开写，这里为了保持内容一致性直接存纯文本
    echo "[${timestamp}] [${level}] ${msg}" >> "$LOG_FILE"
}

# 检查依赖
check_dependency() {
    if ! command -v fswatch &> /dev/null; then
        log "ERROR" "未找到 fswatch，请先安装 (brew install fswatch 或 apt install fswatch)"
        exit 1
    fi

    if [ ! -d "$LOCAL_DIR" ]; then
        log "ERROR" "本地目录不存在: $LOCAL_DIR"
        exit 1
    fi
}

# 测试 SSH 连接
check_connection() {
    log "INFO" "正在测试与 $REMOTE_HOSTNAME 的连接..."
    if ssh -q -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE_HOSTNAME" exit; then
        log "SUCCESS" "SSH 连接正常"
    else
        log "ERROR" "无法连接到远程主机 $REMOTE_HOSTNAME，请检查网络或 SSH 配置。"
        exit 1
    fi
}

# 同步核心逻辑
sync_to_remote() {
    local trigger_reason="$1"

    log "INFO" ">>> 开始同步 (触发: $trigger_reason)"
    echo -e "\033[36m--- 变更文件 ---\033[0m"

    # 核心：rsync -> stderr转stdout -> tee(写文件) -> grep(过滤屏幕显示)
    rsync "${RSYNC_OPTS[@]}" "${EXCLUDES[@]}" "$LOCAL_DIR" "$REMOTE_HOSTNAME:$REMOTE_DIR" \
        2>&1 \
        | tee -a "$LOG_FILE" \
        | grep -vE '^sending incremental file list$|^$|^sent [0-9,]+ bytes|^total size is'

    # 获取管道链中第一个命令(rsync)的退出码
    local rsync_status=${PIPESTATUS[0]}

    if [ $rsync_status -eq 0 ]; then
        log "SUCCESS" "同步完成"
    else
        echo -e "\033[36m----------------\033[0m"
        log "ERROR" "同步失败 (Code: $rsync_status) - 详情见日志"
    fi
}

# 退出清理
cleanup() {
    echo ""
    log "WARN" "🛑 服务已停止"
    exit 0
}
trap cleanup INT TERM

# ================== 主程序 ==================

check_dependency
check_connection

echo "========================================"
echo "🚀 自动同步服务已启动"
echo "📂 本地目录: $LOCAL_DIR"
echo "📡 远程目标: $REMOTE_HOSTNAME:$REMOTE_DIR"
echo "📝 日志文件: $LOG_FILE"
echo "========================================"

# 首次全量同步
sync_to_remote "首次启动"

log "INFO" "正在监听文件变更..."

# 监听循环
# -o: 输出变更事件数量
# -l 1: 延迟 1 秒
# -r: 递归
# --event ...: 也可以指定只监听 Updated, Created, Removed 等，这里默认全监听
fswatch -o -l 1 -r "$LOCAL_DIR"\
    --event Created --event Updated --event Removed --event Renamed --event MovedTo --event MovedFrom \
    | while read num; do
    sync_to_remote "检测到文件变更"
done
