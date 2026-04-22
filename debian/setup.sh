#!/usr/bin/env bash
# Debian 13 开发机初始化脚本（幂等，可重复运行）
# 用法：bash debian/setup.sh
set -euo pipefail

log() { echo -e "\033[1;36m==>\033[0m $*"; }

# ---------- 1. 换清华源（只换一次） ----------
SOURCES=/etc/apt/sources.list.d/debian.sources
if [[ -f "$SOURCES" ]] && ! grep -q tuna.tsinghua "$SOURCES"; then
  log "切换到清华镜像"
  sudo sed -i.bak 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' "$SOURCES"
  sudo sed -i 's|security.debian.org|mirrors.tuna.tsinghua.edu.cn/debian-security|g' "$SOURCES"
fi

# ---------- 2. apt 包（apt install 本身就幂等） ----------
# 非交互 + 遇到已修改的 conffile（如 Lima 定制过的 sshd_config）保留旧版，
# 不弹 debconf 问答框，幂等跑脚本用
export DEBIAN_FRONTEND=noninteractive
APT_OPTS=(-o 'Dpkg::Options::=--force-confold' -o 'Dpkg::Options::=--force-confdef')

log "apt update"
sudo apt-get update -qq

APT_PACKAGES=(
  # 基础
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

  # 编辑器
  neovim vim

  # 网络
  openssh-client
  dnsutils
  net-tools

  # 语言 / 运行时（系统包，版本可能略旧；新版本见下方外部安装）
  python3 python3-pip python3-venv
)
# docker 不走 apt（Debian 13 的 docker.io / docker-compose 状态不稳定），
# 用 Docker 官方脚本装 docker-ce + compose 插件，版本新且跨 Debian 版本都能用

log "装 apt 包（共 ${#APT_PACKAGES[@]} 个）"
sudo apt-get install -y --no-install-recommends "${APT_OPTS[@]}" "${APT_PACKAGES[@]}"

# fd-find 的二进制叫 fdfind，软链成 fd
if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi
# bat 同理
if ! command -v bat >/dev/null && command -v batcat >/dev/null; then
  sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# ---------- 3. 外部二进制（每个都检查是否已装） ----------
# docker 暂不自动装：Debian 13 arm64 下官方脚本会拉 docker-model-plugin 等
# 新插件，有时 dpkg 会挂。需要时手动：curl -fsSL https://get.docker.com | sudo sh

# Node（官方 tarball 直装到 /opt/node；不用 fnm/nvm 之类版本管理器）
# 升级 Node：改下面 NODE_VERSION 再重跑脚本即可
NODE_VERSION="22.19.0"
if ! command -v node >/dev/null || ! node --version 2>/dev/null | grep -q "$NODE_VERSION"; then
  log "装 Node $NODE_VERSION"
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
  log "node $NODE_VERSION 已装"
fi

# pnpm（standalone installer，不依赖 npm）
if ! command -v pnpm >/dev/null; then
  log "装 pnpm"
  curl -fsSL https://get.pnpm.io/install.sh | sh -
else
  log "pnpm 已装 ($(pnpm --version))"
fi

# claude code（npm 全局装，软链到 /usr/local/bin 方便 PATH 寻址）
if ! command -v claude >/dev/null; then
  log "装 claude code"
  npm install -g @anthropic-ai/claude-code
  sudo ln -sf /opt/node/bin/claude /usr/local/bin/claude
else
  log "claude code 已装 ($(claude --version 2>/dev/null | head -1))"
fi

# lazygit（Debian 仓库没有，走 release tarball）
if ! command -v lazygit >/dev/null; then
  log "装 lazygit"
  ARCH=$(uname -m); case "$ARCH" in aarch64) LG_ARCH=arm64 ;; x86_64) LG_ARCH=x86_64 ;; esac
  LG_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | grep tag_name | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz" \
    | tar -xz -C "$TMP" lazygit
  sudo install "$TMP/lazygit" /usr/local/bin/
  rm -rf "$TMP"
else
  log "lazygit 已装"
fi

log "完成。建议 exec \$SHELL 或重开 terminal 让 PATH / docker 组生效。"
