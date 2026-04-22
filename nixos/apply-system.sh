#!/bin/bash

# Nix 配置应用脚本
# 用法: ./apply-system.sh <vm|host|darwin>
# - vm: 应用虚拟机配置（无 GUI）
# - host: 应用实体机配置（有 GUI）
# - darwin: 应用 macOS 配置

CONFIG_TYPE="$1"
FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIRROR="https://mirrors.bfsu.edu.cn/nix-channels/store"

case "$CONFIG_TYPE" in
  vm)            FLAKE_TARGET="nyx-vm" ;;
  host)          FLAKE_TARGET="nyx" ;;
  vm-2604)       FLAKE_TARGET="nyx-vm-2604" ;;
  vm-min-2604)   FLAKE_TARGET="nyx-vm-min-2604" ;;
  host-2604)     FLAKE_TARGET="nyx-host-2604" ;;
  server-2604)   FLAKE_TARGET="nyx-server-2604" ;;
  wsl)           FLAKE_TARGET="nyx-wsl" ;;
  darwin)        FLAKE_TARGET="nyx-darwin" ;;
  *)
    echo "用法: $0 <vm|host|vm-2604|vm-min-2604|host-2604|server-2604|wsl|darwin>"
    exit 1
    ;;
esac

echo "正在应用 $FLAKE_TARGET ..."
if [ "$CONFIG_TYPE" = "darwin" ]; then
  # 首次安装使用: nix run nix-darwin -- switch --flake .#nyx-darwin
  darwin-rebuild switch \
    --flake "${FLAKE_DIR}#$FLAKE_TARGET" \
    --option substituters "$MIRROR"
else
  sudo nixos-rebuild switch \
    --flake "${FLAKE_DIR}#$FLAKE_TARGET" \
    --impure \
    --option substituters "$MIRROR"
fi
