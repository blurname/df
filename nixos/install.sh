#!/usr/bin/env bash
# NixOS 一键安装脚本（从官方 live ISO 运行）
# 用法: sudo bash install.sh <vm-2604|vm-min-2604|host-2604|server-2604>
# 新装机一律走运行时 disko 路径（yymm target，详见 DISKO.md）。
# 旧的 nyx-vm / nyx target 只供现有机器 apply-system.sh 继续 rebuild。
set -euo pipefail

TARGET="${1:-}"
USER_NAME="bl"
REPO_URL="https://github.com/blurname/df.git"
# bfsu 主要覆盖 x86_64；aarch64 很多包没镜像，落回 cache.nixos.org 避免本地编译
MIRROR="https://mirrors.bfsu.edu.cn/nix-channels/store https://cache.nixos.org"
IMPERMANENCE=no

case "$TARGET" in
  vm-2604)       FLAKE_TARGET="nyx-vm-2604" ;;
  vm-min-2604)   FLAKE_TARGET="nyx-vm-min-2604" ;;
  host-2604)     FLAKE_TARGET="nyx-host-2604" ;;
  server-2604)   FLAKE_TARGET="nyx-server-2604"; IMPERMANENCE=yes ;;
  *) echo "用法: sudo bash $0 <vm-2604|vm-min-2604|host-2604|server-2604>"; exit 1 ;;
esac

[[ $EUID -eq 0 ]] || { echo "必须以 root 运行"; exit 1; }

# 探测磁盘: NVMe → virtio → SATA/SCSI
DEV=""
for d in /dev/nvme0n1 /dev/vda /dev/sda; do
  [[ -b "$d" ]] && DEV="$d" && break
done
[[ -n "$DEV" ]] || { echo "未找到可用磁盘 (nvme0n1/vda/sda)"; exit 1; }

echo "========================================"
echo "目标:  $FLAKE_TARGET"
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
if [[ "$IMPERMANENCE" = yes ]]; then
  DISKO_FILE="$REPO/nixos/sub/server/disko.nix"
else
  DISKO_FILE="$REPO/nixos/disko.nix"
fi
nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount \
  "$DISKO_FILE" \
  --argstr device "$DEV"

# impermanence 需要 @blank 只读快照作为回滚目标，必须在 @root 被写入前拍
if [[ "$IMPERMANENCE" = yes ]]; then
  echo "==> 创建 @blank 只读快照"
  mkdir -p /btrfs_tmp
  mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp
  btrfs subvolume snapshot -r /btrfs_tmp/@root /btrfs_tmp/@blank
  umount /btrfs_tmp
fi

# 把实际 device 传给 NixOS 模块（disko 默认 /dev/sda）
if [[ "$DEV" != "/dev/sda" ]]; then
  cat > "$REPO/nixos/local.nix" <<EOF
{ lib, ... }: {
  disko.devices.disk.main.device = "$DEV";
}
EOF
fi

echo "==> 生成 hardware-configuration.nix"
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/

# impermanence: 预填 /persist（hw-config + machine-id + ssh host keys），
# 否则首次重启回滚后 sshd 会重新生成 key，指纹变化；machine-id 变化也会让日志分段
if [[ "$IMPERMANENCE" = yes ]]; then
  echo "==> 预填 /persist"
  mkdir -p /mnt/persist/etc/nixos /mnt/persist/etc/ssh
  cp /mnt/etc/nixos/hardware-configuration.nix /mnt/persist/etc/nixos/
  systemd-id128 new > /mnt/persist/etc/machine-id
  ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -q
  ssh-keygen -t rsa -b 3072 -f /mnt/persist/etc/ssh/ssh_host_rsa_key -N "" -q
fi

mkdir -p "/mnt/home/$USER_NAME"
mv "$REPO" "/mnt/home/$USER_NAME/df"

# 低内存 VM（<=8GB）在 aarch64 上装机时，nix-util 等包需要本地编译 C++，
# 容易被 OOM killer 干掉。在 /mnt 上临时加 swap 撑过 build，装完清理。
# btrfs 的 swap 文件必须先 chattr +C（关 CoW 和压缩）再写内容
echo "==> 添加临时 swap (8G)"
touch /mnt/swapfile
chattr +C /mnt/swapfile 2>/dev/null || true
dd if=/dev/zero of=/mnt/swapfile bs=1M count=8192 status=progress
chmod 600 /mnt/swapfile
mkswap -q /mnt/swapfile
swapon /mnt/swapfile
# 校验 swap 真的上了（btrfs 配置冲突会让 swapon 静默失败）
if ! grep -q /mnt/swapfile /proc/swaps; then
  echo "ERROR: swapon /mnt/swapfile 失败，装机大概率会 OOM"; exit 1
fi
free -h

cleanup_swap() {
  swapoff /mnt/swapfile 2>/dev/null || true
  rm -f /mnt/swapfile
}
trap cleanup_swap EXIT

# --cores 1 --max-jobs 1 把 nix build 的并行度压到单线程，
# 峰值内存降 3-4 倍，慢但不 OOM。低内存 VM 装机的保险策略。
echo "==> nixos-install (single-threaded build)"
nixos-install \
  --flake "/mnt/home/$USER_NAME/df#$FLAKE_TARGET" \
  --impure \
  --option substituters "$MIRROR" \
  --option cores 1 \
  --option max-jobs 1 \
  --no-root-password

cleanup_swap
trap - EXIT

nixos-enter --root /mnt -c "chown -R $USER_NAME:users /home/$USER_NAME/df"

cat <<EOF

========================================
安装完成

1. reboot
2. 登录 $USER_NAME (密码: b)
3. cd ~/df && npm run sync-home-config
========================================
EOF
