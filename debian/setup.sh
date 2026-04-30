#!/usr/bin/env bash
# Debian 13 host bootstrap — full CLI + GUI desktop (mirrors NixOS host config).
# Idempotent: safe to re-run. For minimal VMs see setup-min-vm.sh.
# Usage: bash debian/setup.sh
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# ---------- 1. apt sources: Tsinghua mirror + contrib/non-free ----------
SOURCES=/etc/apt/sources.list.d/debian.sources
if [[ -f "$SOURCES" ]] && ! grep -q tuna.tsinghua "$SOURCES"; then
  log "Switching apt to Tsinghua mirror"
  sudo sed -i.bak 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' "$SOURCES"
  sudo sed -i 's|security.debian.org|mirrors.tuna.tsinghua.edu.cn/debian-security|g' "$SOURCES"
fi
if [[ -f "$SOURCES" ]] && ! grep -qE '^Components:.*non-free' "$SOURCES"; then
  log "Enabling contrib + non-free components (for unrar, fonts, firmware)"
  sudo sed -i -E 's|^Components:.*|Components: main contrib non-free non-free-firmware|' "$SOURCES"
fi

export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-o 'Dpkg::Options::=--force-confold' -o 'Dpkg::Options::=--force-confdef')

log "apt update"
sudo apt-get update -qq

# ---------- 2. apt packages ----------
# Mirrors nixos/sub/common/{cli,editor,language,docker}.nix and
# nixos/sub/host/gui/{minigui,wayland,font}.nix where Debian equivalents exist.
APT_PACKAGES=(
  # base / build
  ca-certificates curl wget gnupg lsb-release
  git
  build-essential gcc make
  pkg-config

  # shell / TUI (cli.nix)
  tmux
  fzf
  ripgrep fd-find bat eza
  jq
  htop btop
  fastfetch neofetch
  unzip zip p7zip-full
  bubblewrap

  # editors (editor.nix)
  neovim vim

  # network
  openssh-client
  dnsutils
  net-tools

  # multimedia (cli.nix + minigui.nix)
  ffmpeg
  mpv

  # language runtimes (language.nix; newer ones below)
  python3 python3-pip python3-venv

  # virtualization (docker.nix)
  virt-manager

  # browsers (minigui.nix)
  firefox-esr

  # screenshot (minigui.nix)
  flameshot

  # input method (minigui.nix)
  fcitx5 fcitx5-chinese-addons

  # fonts (font.nix)
  fonts-noto-cjk fonts-noto-cjk-extra

  # archives (minigui.nix)
  unrar
)

log "Installing apt packages (${#APT_PACKAGES[@]} total)"
# Try one bulk install; on failure, fall back to per-package so a single
# missing package doesn't abort the whole run.
if ! sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "${APT_PACKAGES[@]}"; then
  log "Bulk install hit a missing package; retrying individually"
  for pkg in "${APT_PACKAGES[@]}"; do
    sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "$pkg" \
      >/dev/null 2>&1 \
      && log "  ok: $pkg" \
      || log "  skip: $pkg (not available)"
  done
fi

# Debian ships fd as fdfind, bat as batcat — symlink to canonical names.
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi
if ! command -v bat >/dev/null && command -v batcat >/dev/null; then
  sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

ARCH=$(uname -m)

# ---------- 3. Google Chrome (official apt repo) ----------
if ! command -v google-chrome >/dev/null && ! command -v google-chrome-stable >/dev/null; then
  if [[ "$ARCH" == "x86_64" ]]; then
    log "Installing Google Chrome"
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
      | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
      | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y google-chrome-stable
  else
    log "Skipping Google Chrome (no official $ARCH build); using firefox-esr"
  fi
fi

# ---------- 4. GitHub CLI (gh) ----------
if ! command -v gh >/dev/null; then
  log "Installing GitHub CLI (gh)"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y gh
fi

# ---------- 5. Node + pnpm + Claude Code + lazygit (same as min-vm) ----------
NODE_VERSION="22.19.0"
if ! command -v node >/dev/null || ! node --version 2>/dev/null | grep -q "$NODE_VERSION"; then
  log "Installing Node $NODE_VERSION"
  case "$ARCH" in
    aarch64) NODE_ARCH=arm64 ;;
    x86_64)  NODE_ARCH=x64 ;;
  esac
  TMP=$(mktemp -d)
  curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
    | tar -xJ -C "$TMP"
  sudo rm -rf /opt/node
  sudo mv "$TMP/node-v${NODE_VERSION}-linux-${NODE_ARCH}" /opt/node
  sudo ln -sf /opt/node/bin/node /usr/local/bin/node
  sudo ln -sf /opt/node/bin/npm /usr/local/bin/npm
  sudo ln -sf /opt/node/bin/npx /usr/local/bin/npx
  rm -rf "$TMP"
else
  log "node $NODE_VERSION already installed"
fi

if ! command -v pnpm >/dev/null; then
  log "Installing pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
else
  log "pnpm already installed ($(pnpm --version))"
fi

if ! command -v claude >/dev/null; then
  log "Installing Claude Code"
  npm install -g @anthropic-ai/claude-code
  sudo ln -sf /opt/node/bin/claude /usr/local/bin/claude
else
  log "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
fi

if ! command -v lazygit >/dev/null; then
  log "Installing lazygit"
  case "$ARCH" in aarch64) LG_ARCH=arm64 ;; x86_64) LG_ARCH=x86_64 ;; esac
  LG_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep tag_name | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz" \
    | tar -xz -C "$TMP" lazygit
  sudo install "$TMP/lazygit" /usr/local/bin/
  rm -rf "$TMP"
else
  log "lazygit already installed"
fi

# ---------- 6. starship (cli.nix) ----------
if ! command -v starship >/dev/null; then
  log "Installing starship"
  curl -fsSL https://starship.rs/install.sh | sudo sh -s -- -y >/dev/null
else
  log "starship already installed"
fi

# ---------- 7. zellij (cli.nix) ----------
if ! command -v zellij >/dev/null; then
  log "Installing zellij"
  case "$ARCH" in aarch64) ZJ_ARCH=aarch64-unknown-linux-musl ;; x86_64) ZJ_ARCH=x86_64-unknown-linux-musl ;; esac
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${ZJ_ARCH}.tar.gz" \
    | tar -xz -C "$TMP"
  sudo install "$TMP/zellij" /usr/local/bin/
  rm -rf "$TMP"
else
  log "zellij already installed"
fi

# ---------- 8. bun (language.nix) ----------
if ! command -v bun >/dev/null; then
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash >/dev/null
  if [[ -x "$HOME/.bun/bin/bun" ]]; then
    sudo ln -sf "$HOME/.bun/bin/bun" /usr/local/bin/bun
  fi
else
  log "bun already installed ($(bun --version))"
fi

# ---------- 9. zig (language.nix) ----------
ZIG_VERSION="0.14.0"
if ! command -v zig >/dev/null; then
  log "Installing zig $ZIG_VERSION"
  case "$ARCH" in aarch64) ZIG_ARCH=aarch64 ;; x86_64) ZIG_ARCH=x86_64 ;; esac
  TMP=$(mktemp -d)
  curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz" \
    | tar -xJ -C "$TMP"
  sudo rm -rf /opt/zig
  sudo mv "$TMP/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}" /opt/zig
  sudo ln -sf /opt/zig/zig /usr/local/bin/zig
  rm -rf "$TMP"
else
  log "zig already installed ($(zig version))"
fi

# ---------- 10. Iosevka font (font.nix) ----------
# Debian's fonts-iosevka may not exist in trixie — install from GitHub release.
if ! fc-list 2>/dev/null | grep -qi iosevka; then
  log "Installing Iosevka font"
  TMP=$(mktemp -d)
  IOSEVKA_VERSION=$(curl -fsSL https://api.github.com/repos/be5invis/Iosevka/releases/latest \
    | grep tag_name | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')
  curl -fsSL "https://github.com/be5invis/Iosevka/releases/download/v${IOSEVKA_VERSION}/PkgTTF-Iosevka-${IOSEVKA_VERSION}.zip" \
    -o "$TMP/iosevka.zip"
  sudo mkdir -p /usr/local/share/fonts/iosevka
  sudo unzip -oq "$TMP/iosevka.zip" -d /usr/local/share/fonts/iosevka
  sudo fc-cache -f >/dev/null
  rm -rf "$TMP"
else
  log "Iosevka font already installed"
fi

log "Done. Run 'exec \$SHELL' or open a new terminal so PATH updates take effect."
log "Note: Docker not installed by this script — see README's Docker section."
