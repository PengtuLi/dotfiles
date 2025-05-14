#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

get_pac_list() {
    # Define the list of standard packages for brew install
    local pac_list_from_brew="gh nvim ghostty git starship tldr lazygit bear tmux"

    # Define the base list of cask packages for brew install --cask
    local cask_pac_list_from_brew="spacedrive"

    # Get the current platform
    local platform
    platform="$(get_platform)"

    # Check if the platform is osx (macOS)
    if [[ "${platform}" == "osx" ]]; then
        cask_pac_list_from_brew="${cask_pac_list_from_brew} rectangle"
    fi

    # Output the two lists, each on a new line
    echo "${pac_list_from_brew}"
    echo "${cask_pac_list_from_brew}"
}

check_zsh_config() {
    # specific zsh config
    if [[ $1 == "starship" ]]; then
        echo >> ~/.zshrc
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
    fi

    if [[ $1 == "tmux" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

}

install_from_brew() {
    if command -v $1 &>/dev/null || [ -e "/Applications/$1.app" ]; then
        warning "$1 has already installed."
    else
        if [[ $2 == "cask" ]]; then
            brew install --cask $1
        else
            brew install $1
        fi
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

    if ! command -v autoliter &>/dev/null; then
        git clone https://github.com/PengtuLi/autoLiterature.git ~/Desktop/autoLiterature/
        cd  ~/Desktop/autoLiterature/
        python setup.py install
        cd $SCRIPT_DIR
    else
        warning "autoLiterature has already installed"
    fi


}

install_software() {
    
    if {
        IFS= read -r pac_list_from_brew
        IFS= read -r cask_pac_list_from_brew
    } < <(get_pac_list); then
        # 函数调用成功，并且成功读取了两行
        echo "普通包列表: ${pac_list_from_brew}"
        echo "Cask包列表: ${cask_pac_list_from_brew}"
    else
        echo "获取包列表失败"
    fi

    for package in $pac_list_from_brew; do
        install_from_brew $package
    done
    for cask_package in $cask_pac_list_from_brew; do
        install_from_brew $cask_package cask
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
