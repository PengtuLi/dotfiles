#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$ROOT_DIR/scripts/lib/common.sh"

# miniconda3
if ! command -v conda &>/dev/null; then
    mkdir -p ~/miniconda3
    if [[ $(get_platform) == "linux" ]]; then
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
    elif [[ $(get_platform) == "osx" ]]; then
        curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
    else
        error "wrong platform"
    fi

    mkdir -p ~/miniconda3
    # 再次确保安装脚本已下载（部分发行版上 curl/wget 可能被替换）
    [[ -f ~/miniconda3/miniconda.sh ]] || wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh

    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
    rm ~/miniconda3/miniconda.sh

    # 初始化 conda
    source ~/miniconda3/bin/activate
    conda init --all
    conda config --set changeps1 False
    source ~/.zshrc

    # 关闭 "(base)" 前缀
    conda config --set changeps1 false
else
    warning "miniconda has already installed"
fi
