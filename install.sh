#!/usr/bin/env bash

# learn how to use gdb

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 调用统一主流程
"$ROOT_DIR/scripts/core/main.sh" "$@"
