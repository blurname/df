#!/bin/bash
#########################################################################
# File Name: amdgpu.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年08月08日 星期六 15时03分22秒
#########################################################################

sudo pacman -S --noconfirm mesa mesa-demos xf86-video-amdgpu
sudo sed -i 's/^MODULES=(/MODULES=(amdgpu/g' /etc/mkinitcpio.conf

sudo mkinitcpio -p linux
