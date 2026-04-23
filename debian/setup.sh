#!/usr/bin/env bash
# Debian 13 dev machine bootstrap (idempotent — safe to re-run)
# Usage: bash debian/setup.sh
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# ---------- 1. Switch to Tsinghua mirror (once) ----------
SOURCES=/etc/apt/sources.list.d/debian.sources
if [[ -f "$SOURCES" ]] && ! grep -q tuna.tsinghua "$SOURCES"; then
  log "Switching apt to Tsinghua mirror"
  sudo sed -i.bak 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' "$SOURCES"
  sudo sed -i 's|security.debian.org|mirrors.tuna.tsinghua.edu.cn/debian-security|g' "$SOURCES"
fi

# ---------- 2. apt packages (apt install is idempotent) ----------
# Non-interactive + keep locally modified conffiles (e.g. Lima's custom
# sshd_config) so rerunning doesn't prompt.
export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-o 'Dpkg::Options::=--force-confold' -o 'Dpkg::Options::=--force-confdef')

log "apt update"
sudo apt-get update -qq

APT_PACKAGES=(
  # base
  ca-certificates curl wget gnupg lsb-release
  git
  build-essential
  pkg-config

  # shell / TUI
  tmux
  fzf
  ripgrep fd-find bat
  jq
  htop btop
  fastfetch
  unzip p7zip-full

  # editors
  neovim vim

  # network
  openssh-client
  dnsutils
  net-tools

  # language runtimes (system versions; newer ones installed below)
  python3 python3-pip python3-venv
)
# Docker is not installed via apt (Debian 13's docker.io / docker-compose
# packaging is unstable). Install manually when needed:
#   curl -fsSL https://get.docker.com | sudo sh

log "Installing apt packages (${#APT_PACKAGES[@]} total)"
sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "${APT_PACKAGES[@]}"

# fd-find ships as `fdfind` on Debian — symlink to `fd`
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi
# same for bat -> batcat
if ! command -v bat >/dev/null && command -v batcat >/dev/null; then
  sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# ---------- 3. External binaries (each checked before install) ----------

# Node (official tarball to /opt/node — no version manager)
# To upgrade: bump NODE_VERSION and re-run this script
NODE_VERSION="22.19.0"
if ! command -v node >/dev/null || ! node --version 2>/dev/null | grep -q "$NODE_VERSION"; then
  log "Installing Node $NODE_VERSION"
  ARCH=$(uname -m); case "$ARCH" in
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

# pnpm (standalone installer, does not need npm)
if ! command -v pnpm >/dev/null; then
  log "Installing pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
else
  log "pnpm already installed ($(pnpm --version))"
fi

# Claude Code (npm global + symlink into /usr/local/bin for PATH)
if ! command -v claude >/dev/null; then
  log "Installing Claude Code"
  npm install -g @anthropic-ai/claude-code
  sudo ln -sf /opt/node/bin/claude /usr/local/bin/claude
else
  log "Claude Code already installed ($(claude --version 2>/dev/null | head -1))"
fi

# lazygit (not in Debian repos, install from GitHub release)
if ! command -v lazygit >/dev/null; then
  log "Installing lazygit"
  ARCH=$(uname -m); case "$ARCH" in aarch64) LG_ARCH=arm64 ;; x86_64) LG_ARCH=x86_64 ;; esac
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

log "Done. Run 'exec \$SHELL' or open a new terminal so PATH updates take effect."
