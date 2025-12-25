#!/bin/bash

# macOS Nix + nix-darwin 初始化脚本
# 用法: ./install-darwin.sh

set -e

FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== macOS Nix 初始化脚本 ==="
echo ""

# 1. 检查并安装 Nix
if command -v nix &> /dev/null; then
  echo "✓ Nix 已安装"
  nix --version
else
  echo "→ 正在安装 Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  echo "✓ Nix 安装完成，请重新打开终端后再次运行此脚本"
  exit 0
fi

# 2. 检查 flakes 是否启用
echo ""
echo "→ 检查 Nix 配置..."
if nix show-config 2>/dev/null | grep -q "experimental-features.*flakes"; then
  echo "✓ Flakes 已启用"
else
  echo "→ 正在启用 Flakes..."
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  echo "✓ Flakes 已启用"
fi

# 3. 安装/更新 nix-darwin
echo ""
if command -v darwin-rebuild &> /dev/null; then
  echo "✓ nix-darwin 已安装"
  echo "→ 正在应用配置..."
  darwin-rebuild switch \
    --flake "${FLAKE_DIR}#nyx-darwin" \
    --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
else
  echo "→ 正在安装 nix-darwin 并应用配置..."
  nix run nix-darwin -- switch \
    --flake "${FLAKE_DIR}#nyx-darwin" \
    --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
fi

echo ""
echo "=== 安装完成 ==="
echo "后续更新配置请使用: npm run flake-apply-darwin"

