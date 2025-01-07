#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

function help() {
    cat >&2 <<EOF
Usage: $0 [--preset <preset>] | [--platform <platform> [OPTIONS] ]

Predefined platform presets:
  macos             → full macOS setup (brew, GUI apps, dotfiles, etc.)
  linux-gui         → Linux desktop with GUI support (archlinux)
  linux-tty         → Linux TTY/server (no GUI)
  linux-container   → Minimal container setup (CLI only)

OPTIONS:
  --install <comp>        Install specific component(s) (comma-separated)
                          Components: proxy, conda, prerequisites, stow, zsh_plugin, shell_scripts, extras, brew_bundle(only for preset)

Examples:
  $0 --preset macos
  $0 --preset linux-gui
  $0 --platform linux --install conda,zsh_plugin
EOF
    exit 1
}

# 解析参数
PRESET=""
PLATFORM=""
INSTALL_COMPONENTS=()

while (( "$#" )); do
    case "$1" in
        --preset)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --preset requires a value" >&2
                help
            fi
            PRESET="$2"
            shift 2
            ;;
        --platform)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --platform requires a value" >&2
                help
            fi
            PLATFORM="$2"
            shift 2
            ;;
        --install)
            if [[ -z "${2:-}" ]]; then
                echo "Error: --install requires a component name" >&2
                help
            fi
            IFS=',' read -ra COMPS <<< "$2"
            for comp in "${COMPS[@]}"; do
                INSTALL_COMPONENTS+=("$comp")
            done
            shift 2
            ;;
        -h|--help)
            help
            ;;
        *)
            echo "Unknown argument: $1" >&2
            help
            ;;
    esac
done

# 校验：必须指定 --preset 或 --platform，但不能同时指定
if [[ -z "$PRESET" && -z "$PLATFORM" ]]; then
    echo "Error: Must specify either --preset or --platform" >&2
    help
fi
if [[ -n "$PRESET" && -n "$PLATFORM" ]]; then
    echo "Error: Cannot specify both --preset and --platform" >&2
    help
fi

# 加载配置文件
CONFIG_FILE="$ROOT_DIR/scripts/config/presets.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Config file not found: $CONFIG_FILE" >&2
    exit 1
fi
source "$CONFIG_FILE"


# 如果指定了预设
if [[ -n "$PRESET" ]]; then
    IS_PRESET=false
    for p in "${SUPPORTED_PRESETS[@]}"; do
        if [[ "$PRESET" == "$p" ]]; then
            IS_PRESET=true
            break
        fi
    done

    if [[ "$IS_PRESET" == false ]]; then
        echo "Error: Unknown preset '$PRESET'. Supported: ${SUPPORTED_PRESETS[*]}" >&2
        help
    fi

    PRESET="$PRESET"
    DEFAULT_COMPONENTS="${MAIN_PRESET_COMPONENTS[$PRESET]}"

    # 推断平台类型
    case "$PRESET" in
        osx)          PLATFORM="osx" ;;
        linux-*)        PLATFORM="linux" ;;
    esac
else
    # 自定义平台：仅允许 --platform，无预设组件
    PLATFORM="$PLATFORM"
    DEFAULT_COMPONENTS=""
fi

# 若未手动指定组件，则使用预设默认值（仅当使用 --preset 时有效）
if [[ ${#INSTALL_COMPONENTS[@]} -eq 0 ]]; then
    if [[ -n "$PRESET" ]]; then
        IFS=',' read -ra INSTALL_COMPONENTS <<< "$DEFAULT_COMPONENTS"
    else
        echo "Error: No components specified. When using --platform, you must use --install to specify components." >&2
        help
    fi
fi

# 执行组件安装函数
run_component() {
    local comp="$1"
    local script_path=""
    local args=()

    case "$comp" in
        proxy)
            script_path="$ROOT_DIR/scripts/core/proxy.sh"
            ;;
        conda)
            script_path="$ROOT_DIR/scripts/core/conda.sh"
            ;;
        prerequisites)
            script_path="$ROOT_DIR/scripts/core/prerequisites.sh"
            args=("$PLATFORM")
            ;;
        brew_bundle)
            script_path="$ROOT_DIR/scripts/core/brew_bundle.sh"
            args=("$PRESET")
            ;;
        stow)
            script_path="$ROOT_DIR/scripts/core/stow.sh"
            args=("$PLATFORM")
            ;;
        zsh_plugin)
            script_path="$ROOT_DIR/scripts/core/zsh_plugin.sh"
            ;;
        shell_scripts)
            script_path="$ROOT_DIR/scripts/core/shell_scripts.sh"
            ;;
        extras)
            script_path="$ROOT_DIR/scripts/extras/${PLATFORM}.sh"
            args=()
            ;;
        *)
            echo "Internal error: unknown component $comp" >&2
            exit 1
            ;;
    esac

    if [[ ! -f "$script_path" ]]; then
        warn "Script not found for component '$comp': $script_path. Skipping."
        return
    fi

    info "[${PLATFORM}] Running: $comp"
    "${script_path}" "${args[@]}"
}

# 执行所有启用的组件
for comp in "${INSTALL_COMPONENTS[@]}"; do
    run_component "$comp"
done

success "Setup completed !"
