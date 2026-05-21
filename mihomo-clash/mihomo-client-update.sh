#!/bin/bash
# Mihomo 客户端配置更新脚本
# 用法:
#   更新配置:    ./mihomo-client-update.sh user:password
#   安装定时任务: ./mihomo-client-update.sh --install-cron [user:password] [interval_minutes] (默认 720)
#   卸载定时任务: ./mihomo-client-update.sh --uninstall-cron
#
# 认证优先级: 命令行参数 > ~/.mihomo-auth 文件 > MIHOMO_AUTH 环境变量
# 环境变量:
#   MIHOMO_URL      - 配置服务器地址
#   MIHOMO_CONFIG   - 本地配置路径 (默认 /etc/mihomo/config.yaml)

set -euo pipefail

MIHOMO_CONFIG="${MIHOMO_CONFIG:-/etc/mihomo/config.yaml}"
AUTH_FILE="$HOME/.mihomo-auth"
CRON_NAME="mihomo-update"

# ── 配置加载 ──

load_config_file() {
    if [[ -f "$AUTH_FILE" ]]; then
        while IFS='=' read -r key value; do
            case "$key" in
                MIHOMO_URL)  FILE_URL="$value" ;;
                MIHOMO_AUTH) FILE_AUTH="$value" ;;
            esac
        done < "$AUTH_FILE"
    fi
}

resolve_url() {
    if [[ -n "${MIHOMO_URL:-}" ]]; then
        echo "$MIHOMO_URL"
    elif [[ -n "${FILE_URL:-}" ]]; then
        echo "$FILE_URL"
    fi
}

resolve_auth() {
    # 优先级: 参数 > 文件 > 环境变量
    if [[ -n "${1:-}" ]]; then
        echo "$1"
    elif [[ -n "${FILE_AUTH:-}" ]]; then
        echo "$FILE_AUTH"
    elif [[ -n "${MIHOMO_AUTH:-}" ]]; then
        echo "$MIHOMO_AUTH"
    fi
}

save_config() {
    local auth="$1"
    local url="$2"
    {
        echo "MIHOMO_AUTH=${auth}"
        echo "MIHOMO_URL=${url}"
    } > "$AUTH_FILE"
    chmod 600 "$AUTH_FILE"
    echo "==> 配置已保存到 ${AUTH_FILE} (权限 600)"
}

load_config_file
MIHOMO_URL="$(resolve_url)"

# ── cron 管理 ──

install_cron() {
    local interval="${1:-720}"

    if [[ "$interval" -lt 5 ]]; then
        echo "ERROR: 间隔不能小于 5 分钟"
        exit 1
    fi

    local script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

    local cron_expr
    if [[ "$interval" -ge 60 ]] && (( interval % 60 == 0 )); then
        cron_expr="0 */$((interval / 60)) * * *"
    else
        cron_expr="*/${interval} * * * *"
    fi

    local cron_line="${cron_expr} ${script_path} >> ${HOME}/.mihomo-cron.log 2>&1 ${CRON_NAME}"

    # 移除旧的
    uninstall_cron silent

    # 添加新的
    (crontab -l 2>/dev/null || true; echo "$cron_line") | crontab -

    local display
    if [[ "$interval" -ge 60 ]] && (( interval % 60 == 0 )); then
        display="$((interval / 60)) 小时"
    else
        display="${interval} 分钟"
    fi
    echo "==> 已安装 cron 任务: 每 ${display} 更新配置"
    echo "    日志: ${HOME}/.mihomo-cron.log"
}

uninstall_cron() {
    local silent="${1:-}"
    local existing
    existing=$(crontab -l 2>/dev/null | grep -v "$CRON_MARKER" || true)
    if [[ -n "$existing" ]]; then
        echo "$existing" | crontab -
    else
        crontab -r 2>/dev/null || true
    fi
    if [[ "$silent" != "silent" ]]; then
        echo "==> 已卸载 cron 任务"
    fi
}

# ── YAML 验证 ──

validate_yaml() {
    local file="$1"
    local python="python3"
    # 优先用 venv 里的 python（有 pyyaml）
    local venv_python
    venv_python="$(cd "$(dirname "$0")" && pwd)/../.venv/bin/python3"
    if [[ -x "$venv_python" ]]; then
        python="$venv_python"
    fi
    if $python -c "import yaml" &>/dev/null; then
        $python -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]))" "$file"
    else
        echo "WARNING: 未找到 pyyaml，跳过 YAML 验证"
        return 0
    fi
}

# ── 热重载 mihomo ──

reload_mihomo() {
    local api_url="${MIHOMO_API_URL:-http://127.0.0.1:9090}"
    local api_secret="${MIHOMO_API_SECRET:-1234}"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -X PUT "${api_url}/configs" \
        -H "Authorization: Bearer ${api_secret}" \
        -H "Content-Type: application/json" \
        -d "{\"path\": \"${MIHOMO_CONFIG}\"}" 2>/dev/null || true)

    if [[ "$http_code" == "204" || "$http_code" == "200" ]]; then
        echo "==> 已通过 API 热重载配置"
    else
        echo "ERROR: API 热重载失败 (HTTP ${http_code:-000})"
        exit 1
    fi
}

# ── 参数解析 ──

ACTION="update"
AUTH_ARG=""
CRON_INTERVAL=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --install-cron)
            ACTION="install-cron"
            shift
            ;;
        --uninstall-cron)
            ACTION="uninstall-cron"
            shift
            ;;
        *)
            if [[ -z "$AUTH_ARG" ]]; then
                AUTH_ARG="$1"
            elif [[ -z "$CRON_INTERVAL" ]]; then
                CRON_INTERVAL="$1"
            fi
            shift
            ;;
    esac
done

# 处理 cron 操作
case "$ACTION" in
    install-cron)
        AUTH="$(resolve_auth "$AUTH_ARG")"
        URL="$(resolve_url)"
        if [[ -z "$AUTH" ]]; then
            echo "ERROR: 安装 cron 需要提供认证信息"
            echo "用法: $0 --install-cron user:password [interval_minutes]"
            exit 1
        fi
        if [[ -z "$URL" ]]; then
            echo "ERROR: 未配置服务器地址"
            echo "请设置环境变量 MIHOMO_URL 或通过 .env.secrets 加载"
            exit 1
        fi
        # 确保 ~/.mihomo-auth 存在（cron 环境读不到 .env.secrets）
        if [[ ! -f "$AUTH_FILE" ]]; then
            save_config "$AUTH" "$URL"
        fi
        install_cron "${CRON_INTERVAL:-720}"
        exit 0
        ;;
    uninstall-cron)
        uninstall_cron
        exit 0
        ;;
esac

# ── 配置更新 ──

AUTH="$(resolve_auth "$AUTH_ARG")"

if [[ -z "$MIHOMO_URL" ]]; then
    echo "ERROR: 未配置服务器地址 (MIHOMO_URL)"
    exit 1
fi

if [[ -z "$AUTH" ]]; then
    echo "ERROR: 需要提供认证信息"
    echo "用法: $0 user:password"
    echo "  或设置环境变量 MIHOMO_AUTH=user:password"
    echo "  或保存到 ${AUTH_FILE}"
    exit 1
fi

CONFIG_URL="${MIHOMO_URL}/config.yaml"
BACKUP="${MIHOMO_CONFIG}.bak"

# 备份当前配置
if [[ -f "$MIHOMO_CONFIG" ]]; then
    echo "==> 备份当前配置到 ${BACKUP}"
    cp "$MIHOMO_CONFIG" "$BACKUP"
fi

# 下载新配置
echo "==> 下载配置..."
HTTP_CODE=$(curl -s -o "$MIHOMO_CONFIG" -w "%{http_code}" -u "$AUTH" "$CONFIG_URL" || true)

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "ERROR: 下载失败 (HTTP $HTTP_CODE)"
    if [[ -f "$BACKUP" ]]; then
        echo "==> 回滚到备份配置"
        mv "$BACKUP" "$MIHOMO_CONFIG"
    fi
    exit 1
fi

echo "==> 配置已保存到 $MIHOMO_CONFIG"

# YAML 有效性验证
echo "==> 验证配置文件..."
if ! validate_yaml "$MIHOMO_CONFIG"; then
    echo "ERROR: 下载的配置 YAML 无效，回滚"
    if [[ -f "$BACKUP" ]]; then
        mv "$BACKUP" "$MIHOMO_CONFIG"
    else
        rm -f "$MIHOMO_CONFIG"
    fi
    exit 1
fi
echo "==> 配置验证通过"

# 热重载 mihomo
reload_mihomo

echo "==> 完成"
