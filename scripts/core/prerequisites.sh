#!/bin/bash

# Get the absolute path of the directory where the script is located
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$ROOT_DIR/scripts/lib/common.sh"

install_xcode() {
    if [[ "$(get_platform)" != "osx" ]]; then
        return
    fi

    info "Installing Apple's CLI tools (prerequisites for Git and Homebrew)..."
    if xcode-select -p >/dev/null; then
        warning "xcode is already installed"
    else
        xcode-select --install
        sudo xcodebuild -license accept
    fi
}

install_homebrew() {
    info "Installing Homebrew..."
    if [[ "$(get_platform)" == "osx" ]]; then
        export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    fi
    if command -v brew &>/dev/null; then
        warning "Homebrew already installed"
    else
        if command -v sudo &>/dev/null; then
            sudo --validate
        fi
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

        if [[ "$(get_platform)" == "linux" ]]; then
            echo >> ~/.zshrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        fi

    fi
}

if [[ "$1" == "osx" ]]; then
    install_xcode
    install_homebrew
elif [[ "$1" == "linux" ]]; then
    install_homebrew
fi
