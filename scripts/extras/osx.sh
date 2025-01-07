#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

# macOS 系统默认设置（可选）
# if [[ "$(uname -s)" == "Darwin" ]]; then
#   "$ROOT_DIR/scripts/osx-defaults.sh" || true
# fi

# autoLiterature
# if ! command -v autoliter &>/dev/null; then
#     git clone https://github.com/PengtuLi/autoLiterature.git ~/autoLiterature/
#     cd  ~/Desktop/autoLiterature/
#     python setup.py install
# else
#     warning "autoLiterature has already installed"
# fi

success "OSX 额外步骤完成"
