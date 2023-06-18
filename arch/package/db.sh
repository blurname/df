#!/bin/bash
#########################################################################
# File Name: db.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020年08月08日 星期六 15时03分22秒
#########################################################################

sudo pacman -S --noconfirm mariadb redis postgresql
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
