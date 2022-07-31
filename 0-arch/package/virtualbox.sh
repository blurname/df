#!/bin/bash
#########################################################################
# File Name: vim.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年08月27日 星期四 00时44分12秒
#########################################################################

sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch virtualbox-guest-iso

sudo gpasswd -a $USER vboxusers

# raw disk
# sudo gpasswd -a $USER disk
# sudo mkdir -p /opt/vbox/vmdk/
# VBoxManage internalcommands createrawvmdk -filename /opt/vbox/vmdk/sda.vmdk -rawdisk /dev/sda