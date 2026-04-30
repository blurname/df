#!/usr/bin/env bash
# Debian user-side bootstrap — settings beyond package install.
# Idempotent. Run after setup.sh.
# Usage: bash debian/setup-user.sh
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# Keyboard: us layout, Caps → Esc.
# Writes /etc/X11/xorg.conf.d/00-keyboard.conf, picked up by SDDM and
# every X11/Wayland session (including KDE on fresh installs).
sudo localectl set-x11-keymap us "" "" caps:escape
log "Keyboard set: us + caps:escape. Logout/login to apply."
