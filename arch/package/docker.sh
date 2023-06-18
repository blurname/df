#!/bin/bash
#########################################################################
# File Name: docker.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年08月10日 星期一 23时11分22秒
#########################################################################

sudo pacman -S --noconfirm docker docker-compose

sudo gpasswd -a $USER docker

# deprecated
# sudo mkdir -p /etc/docker/
# echo '{"registry-mirrors":["https://hub-mirror.c.163.com"]}' | sudo tee -a /etc/docker/daemon.json
