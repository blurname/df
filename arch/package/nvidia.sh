#!/bin/bash
#########################################################################
# File Name: nvidia.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2021年02月14日 星期日 18时32分12秒
#########################################################################

sudo pacman -S --noconfirm nvidia

LANG=en_US.UTF-8

sudo sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm/g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux

# grub:
# sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1 /g' /etc/default/grub
# sudo grub-mkconfig -o /boot/grub/grub.cfg

# systemd-boot:
sudo sed -i '/^options/ s/$/ nvidia-drm.modeset=1/' /boot/loader/entries/arch.conf
sudo sed -i '/^options/ s/$/ nvidia-drm.modeset=1/' /boot/loader/entries/arch-fallback.conf

sudo mkdir -p /etc/pacman.d/hooks/
sudo tee /etc/pacman.d/hooks/nvidia.hook > /dev/null <<EOF
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF
