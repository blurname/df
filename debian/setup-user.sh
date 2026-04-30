#!/usr/bin/env bash
# Debian user-side bootstrap — settings that go beyond package install.
# Idempotent. Run after setup.sh.
# Usage: bash debian/setup-user.sh
#
# Currently handles: keyboard (us layout, Caps → Esc).
# Planned: shell, git identity, dotfile symlinks (script/01-link-config.ts),
# fcitx5 env, ssh authorized_keys.
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# ---------- Keyboard: us layout, Caps → Esc ----------
# Mirrors NixOS console.keyMap = "us" + the only non-default remap in
# config/.Xmodmap (keycode 66 / CapsLock → Escape).
#
# Writing two layers because they cover different sessions:
#   - localectl set-x11-keymap → /etc/X11/xorg.conf.d/00-keyboard.conf
#     Used by: SDDM login screen, X11 sessions, Wayland sessions without
#     a per-user override (Hyprland, GNOME).
#   - ~/.config/kxkbrc → KDE Plasma per-user override, overrides the
#     system xkb config inside a Plasma session (X11 or Wayland).

KBD_FILE=/etc/X11/xorg.conf.d/00-keyboard.conf
if ! sudo grep -q 'caps:escape' "$KBD_FILE" 2>/dev/null; then
  log "Setting system keymap (TTY us, X11/Wayland us + caps:escape)"
  sudo localectl set-keymap us
  sudo localectl set-x11-keymap us "" "" caps:escape
else
  log "System keymap already configured ($KBD_FILE has caps:escape)"
fi

# KDE Plasma per-user override. kwriteconfig6 ships with Plasma 6 (Debian
# 13 default); fall back to kwriteconfig5 for older setups.
KWRITE=
if command -v kwriteconfig6 >/dev/null 2>&1; then KWRITE=kwriteconfig6
elif command -v kwriteconfig5 >/dev/null 2>&1; then KWRITE=kwriteconfig5
fi
if [[ -n "$KWRITE" ]]; then
  log "Configuring KDE Plasma keyboard ($KWRITE → ~/.config/kxkbrc)"
  $KWRITE --file kxkbrc --group Layout --key Use true
  $KWRITE --file kxkbrc --group Layout --key LayoutList us
  $KWRITE --file kxkbrc --group Layout --key Options caps:escape
  $KWRITE --file kxkbrc --group Layout --key ResetOldOptions true
else
  log "Skipping KDE kxkbrc (no kwriteconfig found — not on Plasma?)"
fi

log "Done. Log out and back in (or restart Plasma) for the keymap to take effect."
log "Verify after relogin:  setxkbmap -query | grep options    # → caps:escape"
