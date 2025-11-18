flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

sudo apt install flatpak

sudo pacman -S flatpak

sudo apt install mesa-utils

export MESA_LOADER_DRIVER_OVERRIDE=d3d12
export GALLIUM_DRIVER=d3d12

sudo apt install -y fcitx5 fcitx5-rime \
fcitx5-frontend-gtk3 fcitx5-frontend-qt5 \
librime-data-luna-pinyin
