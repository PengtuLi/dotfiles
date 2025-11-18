#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

install_SMB(){

    # nas
    sudo chmod 644 $ROOT_DIR/stow/gui/nas/smb.conf
    sudo mkdir -p /etc/samba/

    # 检查目标文件是否存在，如果存在则删除
    # if [ -e /etc/samba/smb.conf ] || [ -L /etc/samba/smb.conf ]; then
    #     sudo rm /etc/samba/smb.conf
    # fi

    # sudo ln -s $ROOT_DIR/scripts/mesh/nas/smb.conf /etc/samba/smb.conf
    sudo smbpasswd -a tutu

    # 启动 SMB 文件共享服务
    sudo systemctl enable --now smb.service

    # 启动 NMB 网络浏览服务（可选，但推荐）
    sudo systemctl enable --now nmb.service


}

read -r -p "reinstall smb?" INSTALL_SMB
case "$INSTALL_SMB" in
    [yY])
        echo "开始安装..."
        install_SMB
esac
