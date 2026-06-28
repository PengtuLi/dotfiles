#!/bin/bash
# Homebrew installation script (reusable for local and remote)
# Supports USTC mirror with official fallback, and optional proxy

set -e

# Proxy support
if [ -n "$HTTP_PROXY" ] || [ -n "$http_proxy" ]; then
    PROXY_URL="${HTTP_PROXY:-$http_proxy}"
    export ALL_PROXY="$PROXY_URL"
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
fi

# Detect brew prefix
BREW_PREFIX=""
if [ -d /home/linuxbrew/.linuxbrew ]; then
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
elif [ -d ~/.linuxbrew ]; then
    BREW_PREFIX="$HOME/.linuxbrew"
fi

# Check if already installed
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/bin/brew" ]; then
    echo "Homebrew already installed at $BREW_PREFIX"
else
    echo "Installing Homebrew..."
    # Try USTC mirror first, fallback to official
    # NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://mirrors.ustc.edu.cn/misc/brew-install.sh)" || \
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Re-detect prefix after installation
BREW_PREFIX=""
if [ -d /home/linuxbrew/.linuxbrew ]; then
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
elif [ -d ~/.linuxbrew ]; then
    BREW_PREFIX="$HOME/.linuxbrew"
fi

if [ -z "$BREW_PREFIX" ]; then
    echo "Error: Homebrew installation failed" >&2
    exit 1
fi

# Add shellenv to shell rc files
SHELLENV_LINE="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""

for rc_file in ~/.bashrc ~/.zshrc ~/.profile; do
    if [ -f "$rc_file" ] && ! grep -q "$BREW_PREFIX/bin/brew shellenv" "$rc_file" 2>/dev/null; then
        echo "" >> "$rc_file"
        echo "$SHELLENV_LINE" >> "$rc_file"
        echo "Added brew shellenv to $rc_file"
    fi
done

echo "Homebrew ready at $BREW_PREFIX"
