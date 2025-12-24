#!/bin/bash

# NixOS 配置应用脚本
# 用法: ./apply-system.sh <vm|host>
# - vm: 应用虚拟机配置（无 GUI）
# - host: 应用实体机配置（有 GUI）

CONFIG_TYPE="$1"

case "$CONFIG_TYPE" in
  vm)
    echo "正在应用虚拟机配置 (nyx-vm)..."
    CONFIG_NAME="nyx-vm"
    ;;
  host)
    echo "正在应用实体机配置 (nyx)..."
    CONFIG_NAME="nyx"
    ;;
  *)
    echo "错误: 必须指定配置类型"
    echo "用法: $0 <vm|host>"
    echo "  vm   - 虚拟机配置（无 GUI）"
    echo "  host - 实体机配置（有 GUI）"
    exit 1
    ;;
esac

sudo nixos-rebuild switch \
  --flake "./nixos#${CONFIG_NAME}" \
  --impure \
  --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
