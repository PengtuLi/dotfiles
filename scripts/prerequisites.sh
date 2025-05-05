#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

install_xcode() {
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
        sudo --validate
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        
        if [[ "$(get_platform)" == "linux" ]]; then
            sudo chown -R root:root /home/linuxbrew/.linuxbrew/Cellar
            sudo chmod -R 777 /home/linuxbrew/.linuxbrew/Cellar
            echo >> ~/.zshrc
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
        fi

    fi
}

if [ "$(basename "$0")" = "$(basename "${BASH_SOURCE[0]}")" ]; then
    install_xcode
    install_homebrew
fi
