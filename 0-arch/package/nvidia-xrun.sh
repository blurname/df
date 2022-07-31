#!/bin/bash
#########################################################################
# File Name: nvidia-xrun.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年08月08日 星期六 15时03分22秒
#########################################################################

sudo pacman -S --noconfirm mesa mesa-demos nvidia xorg-xinit
pikaur -S --noconfirm nvidia-xrun-git

sudo systemctl enable nvidia-xrun-pm

mkdir -p ~/.config/X11/
cat >~/.config/X11/nvidia-xinitrc <<EOF
if [ \$# -gt 0 ]; then
    \$*
else
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx

    startplasma-x11
fi
EOF
