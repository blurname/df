#!/usr/bin/env bash
# Debian user-side bootstrap — settings beyond package install.
# Idempotent. Run after setup.sh.
# Usage: bash debian/setup-user.sh
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# Keyboard: us layout, Caps → Esc.
# Write the X11 xkb config directly. localectl needs console keymap
# data (kbd package) which Debian 13 minimal doesn't ship.
sudo tee /etc/X11/xorg.conf.d/00-keyboard.conf >/dev/null <<'EOF'
Section "InputClass"
    Identifier "system-keyboard"
    MatchIsKeyboard "on"
    Option "XkbLayout" "us"
    Option "XkbOptions" "caps:escape"
EndSection
EOF
log "Keyboard set: us + caps:escape. Logout/login to apply."
