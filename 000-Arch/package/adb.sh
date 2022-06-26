#!/bin/bash
#########################################################################
# File Name: adb.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年09月01日 星期二 18时12分01秒
#########################################################################

sudo pacman -S android-tools android-udev

sudo gpasswd -a $USER adbusers
