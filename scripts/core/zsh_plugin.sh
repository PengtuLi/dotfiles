# legacy code

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$ROOT_DIR/scripts/lib/common.sh"

# if [ ! -d "$HOME/.zsh/antidote" ]; then
#     git clone --depth=1 https://github.com/mattmc3/antidote.git $HOME/.zsh/antidote
#     ls ~/workspace/dotfiles/shell/zsh/zsh-plugin/.zsh_plugins.txt $HOME/.zsh_plugins.txt
#     append_to_zshrc_if_missing "# ------antidote"
#     append_to_zshrc_if_missing 'source ~/.zsh/antidote/antidote.zsh'
#     append_to_zshrc_if_missing "antidote load"
#     append_to_zshrc_if_missing "# ------"
# else
#     warning "antidote has already installed"
# fi

# -------------------------------------------------------------
exit 0
warning "zsh-plugin.zsh is deprecated, use antidote instead"

mkdir -p $HOME/.zsh

zsh-syntax-highlighting
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
