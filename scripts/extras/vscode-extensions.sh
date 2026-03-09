#!/bin/bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

install_vscode_extensions() {
    # List of Extensions
    extensions=(
        ms-python.python
        vscode-icons-team.vscode-icons
        ms-azuretools.vscode-docker
        enkia.tokyo-night
        ms-toolsai.jupyter
        ms-vscode-remote.remote-ssh
    )

    for e in "${extensions[@]}"; do
        code --install-extension "$e"
    done

    success "VSCode extensions installed successfully"
}

if command -v code &> /dev/null; then
    install_vscode_extensions
fi
