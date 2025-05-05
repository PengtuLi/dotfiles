#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

pac_list_from_brew="gh nvim ghostty git starship tldr lazygit"

check_zsh_config() {
    # specific zsh config
    if [[ $1 == "starship" ]]; then
        echo >> ~/.zshrc
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    fi
}

install_from_brew() {
    if command -v $1 &>/dev/null; then
        warning "$1 has already installed."
    else
        brew install $1
        check_zsh_config $1
    fi

}

install_from_shell() {
    mkdir -p $HOME/.zsh

    # zsh-syntax-highlighting
    if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
        echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    else
        warning "zsh-syntax-highlighting has already installed"
    fi
    # zsh-autosuggestions
    if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
        echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    else
        warning "zsh-autosuggestions has already installed"
    fi
    # zsh-completions
    if [ ! -d "$HOME/.zsh/zsh-completions" ]; then
        git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
        echo "source ~/.zsh/zsh-completions/zsh-completions.plugin.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    else
        warning "zsh-completions has already installed"
    fi
    # zsh-autocomplete
    if [ ! -d "$HOME/.zsh/zsh-autocomplete" ]; then
        git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $HOME/.zsh/zsh-autocomplete
        echo "source $HOME/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc
    else
        warning "zsh-autocomplete has already installed"
    fi

    # autojump
    if ! command -v j &>/dev/null; then
        git clone https://github.com/wting/autojump.git ~/.zsh/autojump
        cd  ~/.zsh/autojump
        python ~/.zsh/autojump/install.py
        cd $SCRIPT_DIR
        echo '[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh' >> $HOME/.zshrc
    else
        warning "autojump has already installed"
    fi
    
    # miniconda3
    if ! command -v conda &>/dev/null; then
        
        if [[ $(get_platform) == "linux" ]]; then
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        elif [[ $(get_platform) == "osx" ]]; then
            curl https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -o ~/miniconda3/miniconda.sh
        fi

        mkdir -p ~/miniconda3
        wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
        bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
        rm ~/miniconda3/miniconda.sh

        source ~/miniconda3/bin/activate
        conda init --all
        source ~/.zshrc
    else
        warning "miniconda has already installed"
    fi

}

install_software() {
    
    for package in $pac_list_from_brew; do
        install_from_brew $package
    done

    install_from_shell
}

install_fonts() {
    
    # nerd font
    if [[ $(get_platform) == "linux" ]]; then
        info "install nerd font jetbrains-mono"
        sudo pacman -S --noconfirm ttf-jetbrains-mono-nerd
    elif [[ $(get_platform) == "osx" ]]; then
        info "install nerd font jetbrains-mono"
        brew install --cask font-jetbrains-mono-nerd-font
    fi
}
