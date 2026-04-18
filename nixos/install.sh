#!/usr/bin/env bash
# NixOS 一键安装脚本（从官方 live ISO 运行）
# 用法: sudo bash install.sh <vm|host>
set -euo pipefail

TARGET="${1:-}"
USER_NAME="bl"
REPO_URL="https://github.com/blurname/df.git"
MIRROR="https://mirrors.bfsu.edu.cn/nix-channels/store"

case "$TARGET" in
  vm|host) ;;
  *) echo "用法: sudo bash $0 <vm|host>"; exit 1 ;;
esac

[[ $EUID -eq 0 ]] || { echo "必须以 root 运行"; exit 1; }

# 探测磁盘: NVMe → virtio → SATA/SCSI
DEV=""
for d in /dev/nvme0n1 /dev/vda /dev/sda; do
  [[ -b "$d" ]] && DEV="$d" && break
done
[[ -n "$DEV" ]] || { echo "未找到可用磁盘 (nvme0n1/vda/sda)"; exit 1; }

echo "========================================"
echo "目标:  nyx-$TARGET"
echo "磁盘:  $DEV  (将被完全清空)"
echo "========================================"
lsblk "$DEV"
echo
read -rp "确认输入 YES 继续: " CONFIRM
[[ "$CONFIRM" = "YES" ]] || { echo "已取消"; exit 1; }

command -v git >/dev/null || nix-env -iA nixos.git

REPO=/tmp/df
rm -rf "$REPO"
git clone "$REPO_URL" "$REPO"

echo "==> disko 分区 + 格式化 + 挂载"
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  "$REPO/nixos/disko.nix" \
  --argstr device "$DEV"

echo "==> 生成 hardware-configuration.nix"
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/

mkdir -p "/mnt/home/$USER_NAME"
mv "$REPO" "/mnt/home/$USER_NAME/df"

echo "==> nixos-install"
nixos-install \
  --flake "/mnt/home/$USER_NAME/df#nyx-$TARGET" \
  --impure \
  --option substituters "$MIRROR" \
  --no-root-password

nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME/df"

cat <<EOF

========================================
安装完成

1. reboot
2. 登录 $USER_NAME (密码: b)
3. cd ~/df && npm run sync-home-config
========================================
EOF
