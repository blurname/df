#!/bin/bash

# Nix 配置应用脚本
# 用法: ./apply-system.sh <vm|host|darwin>
# - vm: 应用虚拟机配置（无 GUI）
# - host: 应用实体机配置（有 GUI）
# - darwin: 应用 macOS 配置

CONFIG_TYPE="$1"
FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$CONFIG_TYPE" in
  vm)
    echo "正在应用虚拟机配置 (nyx-vm)..."
    sudo nixos-rebuild switch \
      --flake "${FLAKE_DIR}#nyx-vm" \
      --impure \
      --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ;;
  host)
    echo "正在应用实体机配置 (nyx)..."
    sudo nixos-rebuild switch \
      --flake "${FLAKE_DIR}#nyx" \
      --impure \
      --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ;;
  darwin)
    echo "正在应用 Darwin 配置 (nyx-darwin)..."
    # 首次安装使用: nix run nix-darwin -- switch --flake .#nyx-darwin
    darwin-rebuild switch \
      --flake "${FLAKE_DIR}#nyx-darwin" \
      --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ;;
  *)
    echo "错误: 必须指定配置类型"
    echo "用法: $0 <vm|host|darwin>"
    echo "  vm     - 虚拟机配置（无 GUI）"
    echo "  host   - 实体机配置（有 GUI）"
    echo "  darwin - macOS 配置"
    exit 1
    ;;
esac
