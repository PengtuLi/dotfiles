#!/bin/bash

. scripts/utils.sh
. scripts/prerequisites.sh
. scripts/osx-defaults.sh
. scripts/symlinks.sh
. scripts/software.sh
. scripts/aliases.sh

info "Dotfiles intallation initialized..."
read -p "Install apps? [y/n] " install_apps
read -p "Install font? [y/n] " install_fonts
read -p "Overwrite existing dotfiles? [y/n] " overwrite_dotfiles

if [[ "$install_apps" == "y" ]]; then
    printf "\n"
    info "===================="
    info "Prerequisites"
    info "===================="

    install_xcode
    install_homebrew

    printf "\n"
    info "===================="
    info "Apps"
    info "===================="
    install_software
fi

if [[ "$install_fonts" == "y" ]]; then

    printf "\n"
    info "===================="
    info "Fonts"
    info "===================="
    install_fonts
fi

# printf "\n"
# info "===================="
# info "OSX System Defaults"
# info "===================="
#
# register_keyboard_shortcuts
# apply_osx_system_defaults
#
printf "\n"
info "===================="
info "Aliases"
info "===================="

add_aliases

printf "\n"
info "===================="
info "Symbolic Links"
info "===================="

chmod +x ./scripts/symlinks.sh
if [[ "$overwrite_dotfiles" == "y" ]]; then
    warning "Deleting existing dotfiles..."
    ./scripts/symlinks.sh --delete --include-files
fi
./scripts/symlinks.sh --create

success "Dotfiles set up successfully."
