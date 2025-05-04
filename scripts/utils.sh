#!/bin/bash

default_color=$(tput sgr 0)
red="$(tput setaf 1)"
yellow="$(tput setaf 3)"
green="$(tput setaf 2)"
blue="$(tput setaf 4)"

info() {
    printf "%s==> %s%s\n" "$blue" "$1" "$default_color"
}

success() {
    printf "%s==> %s%s\n" "$green" "$1" "$default_color"
}

error() {
    printf "%s==> %s%s\n" "$red" "$1" "$default_color"
}

warning() {
    printf "%s==> %s%s\n" "$yellow" "$1" "$default_color"
}

get_platform() {
    local kernel_name
    kernel_name="$(uname -s)"
    if [[ "${kernel_name}" == "Darwin" ]]; then
        echo "osx"
    elif [[ "${kernel_name}" == "Linux" ]]; then
        echo "linux"
    else
        error "unsupport platform"
    fi
}
