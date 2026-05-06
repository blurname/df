#!/usr/bin/env bash
# Debian 13 dev environment bootstrap (CLI by default; --gui for desktop).
# Idempotent: safe to re-run. fail-fast on apt errors — re-run after fixing.
# Usage:
#   bash debian/setup.sh           # CLI only — Lima VM, headless dev
#   bash debian/setup.sh --gui     # CLI + GUI desktop apps + Chrome + Iosevka
set -euo pipefail

GUI=0
[[ "${1:-}" == "--gui" ]] && GUI=1

log() { echo -e "\033[1;36m==>\033[0m $*"; }

ARCH=$(uname -m)

# ---------- 1. apt sources: Tsinghua mirror (+ contrib/non-free for GUI) ----------
SOURCES=/etc/apt/sources.list.d/debian.sources
if [[ -f "$SOURCES" ]] && ! grep -q tuna.tsinghua "$SOURCES"; then
  log "Switching apt to Tsinghua mirror"
  sudo sed -i.bak 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' "$SOURCES"
  sudo sed -i 's|security.debian.org|mirrors.tuna.tsinghua.edu.cn/debian-security|g' "$SOURCES"
fi
if (( GUI )) && [[ -f "$SOURCES" ]] && ! grep -qE '^Components:.*non-free' "$SOURCES"; then
  log "Enabling contrib + non-free (unrar, fonts, firmware)"
  sudo sed -i -E 's|^Components:.*|Components: main contrib non-free non-free-firmware|' "$SOURCES"
fi

export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-o 'Dpkg::Options::=--force-confold' -o 'Dpkg::Options::=--force-confdef')

log "apt update"
sudo apt-get update -qq

# ---------- 2. apt packages ----------
# Mirrors nixos/sub/common/{cli,editor,language,docker}.nix (CLI) and
# nixos/sub/host/gui/{minigui,wayland,font}.nix (GUI).
CLI_PACKAGES=(
  ca-certificates curl wget gnupg lsb-release
  git
  build-essential pkg-config
  elvish
  tmux fzf
  ripgrep fd-find bat eza
  jq
  htop btop
  fastfetch
  unzip zip p7zip-full
  bubblewrap
  neovim vim
  openssh-client dnsutils net-tools
  ffmpeg
  python3 python3-pip python3-venv
)
GUI_PACKAGES=(
  mpv
  firefox-esr
  flameshot
  fcitx5 fcitx5-chinese-addons
  fonts-noto-cjk fonts-noto-cjk-extra
  unrar
  virt-manager
)

log "Installing CLI packages (${#CLI_PACKAGES[@]})"
sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "${CLI_PACKAGES[@]}"

if (( GUI )); then
  log "Installing GUI packages (${#GUI_PACKAGES[@]})"
  sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "${GUI_PACKAGES[@]}"
fi

# ---------- 3. GitHub CLI (gh) ----------
if ! command -v gh >/dev/null; then
  log "Installing gh"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg status=none
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y gh
fi

# ---------- 4. Node + pnpm + Claude Code + lazygit ----------
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
  sudo ln -sf /opt/node/bin/npm  /usr/local/bin/npm
  sudo ln -sf /opt/node/bin/npx  /usr/local/bin/npx
  rm -rf "$TMP"
fi

# /opt/node/bin on PATH so `npm i -g <pkg>` binaries are reachable in new shells.
if [[ ! -f /etc/profile.d/node.sh ]]; then
  echo 'export PATH=/opt/node/bin:$PATH' | sudo tee /etc/profile.d/node.sh >/dev/null
fi

if ! command -v pnpm >/dev/null; then
  log "Installing pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

if ! command -v claude >/dev/null; then
  log "Installing Claude Code"
  npm install -g @anthropic-ai/claude-code
  sudo ln -sf /opt/node/bin/claude /usr/local/bin/claude
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
fi

# ---------- 5. starship + zellij + bun + zig ----------
if ! command -v starship >/dev/null; then
  log "Installing starship"
  curl -fsSL https://starship.rs/install.sh | sudo sh -s -- -y >/dev/null
fi

if ! command -v zellij >/dev/null; then
  log "Installing zellij"
  case "$ARCH" in aarch64) ZJ_ARCH=aarch64-unknown-linux-musl ;; x86_64) ZJ_ARCH=x86_64-unknown-linux-musl ;; esac
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${ZJ_ARCH}.tar.gz" | tar -xz -C "$TMP"
  sudo install "$TMP/zellij" /usr/local/bin/
  rm -rf "$TMP"
fi

if ! command -v bun >/dev/null; then
  log "Installing bun"
  curl -fsSL https://bun.sh/install | bash >/dev/null
  [[ -x "$HOME/.bun/bin/bun" ]] && sudo ln -sf "$HOME/.bun/bin/bun" /usr/local/bin/bun
fi

ZIG_VERSION="0.14.0"
if ! command -v zig >/dev/null; then
  log "Installing zig $ZIG_VERSION"
  case "$ARCH" in aarch64) ZIG_ARCH=aarch64 ;; x86_64) ZIG_ARCH=x86_64 ;; esac
  TMP=$(mktemp -d)
  curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz" | tar -xJ -C "$TMP"
  sudo rm -rf /opt/zig
  sudo mv "$TMP/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}" /opt/zig
  sudo ln -sf /opt/zig/zig /usr/local/bin/zig
  rm -rf "$TMP"
fi

# ---------- 6. GUI-only: Chrome + Iosevka font ----------
if (( GUI )); then
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
      log "Skip Google Chrome (no official $ARCH build); use firefox-esr"
    fi
  fi

  # Iosevka not in Debian repos — install from GitHub release.
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
  fi
fi

log "Done. Open a new shell or 'exec \$SHELL' so PATH updates apply."
(( GUI )) || log "CLI-only install. Re-run with --gui for desktop apps."
