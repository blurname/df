#!/usr/bin/env bash
# Debian 13 bare-metal installer (run from any Linux live ISO).
# Mirrors the architecture of nixos/install.sh: disk -> debootstrap ->
# chroot -> kernel+bootloader+user -> reboot-ready system.
#
# Usage (boot a Debian/Ubuntu live ISO, open a terminal):
#   sudo bash install-host.sh <vm-2604|host-2604>
#
# What it does:
#   1. Partitions the detected disk (GPT: 512M ESP + btrfs root)
#   2. Creates btrfs subvolumes @root and @home
#   3. debootstraps Debian 13 (trixie) via Tsinghua mirror
#   4. chroots to install: kernel, GRUB-EFI, NetworkManager, sshd,
#      locale, timezone, user bl, Tsinghua apt sources
#   5. Clones this df repo to /home/bl/df so you can run
#      `bash debian/setup.sh` after first boot to install the toolchain.

set -euo pipefail

TARGET="${1:-}"
USER_NAME="bl"
USER_PASS="b"
HOSTNAME="deb-host"
MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian"
SEC_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/debian-security"
REPO_URL="https://github.com/blurname/df.git"
DEBIAN_VERSION="trixie"

case "$TARGET" in
  vm-2604)   INCLUDE_FIRMWARE=no  ;;   # VMs rarely need firmware blobs
  host-2604) INCLUDE_FIRMWARE=yes ;;   # physical hw wants WiFi/BT firmware etc.
  *) echo "Usage: sudo bash $0 <vm-2604|host-2604>"; exit 1 ;;
esac

[[ $EUID -eq 0 ]] || { echo "Must run as root"; exit 1; }

case "$(uname -m)" in
  aarch64) ARCH=arm64 ;;
  x86_64)  ARCH=amd64 ;;
  *) echo "Unsupported arch: $(uname -m)"; exit 1 ;;
esac

# Pick first available block device: NVMe > virtio > SATA/SCSI
DEV=""
for d in /dev/nvme0n1 /dev/vda /dev/sda; do
  [[ -b "$d" ]] && DEV="$d" && break
done
[[ -n "$DEV" ]] || { echo "No disk found (checked nvme0n1/vda/sda)"; exit 1; }

cat <<EOF
========================================
Target:   $TARGET
Arch:     $ARCH
Disk:     $DEV  (ENTIRE DISK WILL BE WIPED)
Hostname: $HOSTNAME
User:     $USER_NAME  (password: $USER_PASS)
========================================
EOF
lsblk "$DEV"
echo
read -rp "Type YES to continue: " CONFIRM
[[ "$CONFIRM" = "YES" ]] || { echo "Cancelled"; exit 1; }

# Ensure required tools exist (live ISO usually has apt)
need() { command -v "$1" >/dev/null; }
if ! need debootstrap || ! need parted || ! need mkfs.btrfs || ! need mkfs.fat; then
  echo "==> Installing required tools on the live ISO"
  if need apt-get; then
    apt-get update -qq
    apt-get install -y --no-install-recommends \
      debootstrap parted btrfs-progs dosfstools arch-install-scripts
  else
    echo "Missing tools but no apt-get. Boot from a Debian/Ubuntu live ISO."
    exit 1
  fi
fi

echo "==> Partitioning $DEV (GPT: ESP + btrfs root)"
parted -s "$DEV" -- mklabel gpt
parted -s "$DEV" -- mkpart ESP  fat32 1MiB 513MiB
parted -s "$DEV" -- set 1 esp on
parted -s "$DEV" -- mkpart root       513MiB 100%

# nvme / mmc / loop devices use pN suffix
case "$DEV" in
  /dev/nvme*|/dev/mmcblk*|/dev/loop*) PART="${DEV}p" ;;
  *)                                   PART="$DEV"   ;;
esac
ESP="${PART}1"
ROOT="${PART}2"

# Let the kernel notice the new partitions
partprobe "$DEV" 2>/dev/null || true
sleep 1

echo "==> Formatting"
mkfs.fat -F 32 -n boot "$ESP"
mkfs.btrfs -f -L debian "$ROOT"

echo "==> Creating btrfs subvolumes @root and @home"
mount "$ROOT" /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
umount /mnt

echo "==> Mounting target filesystems at /mnt"
mount -o subvol=@root,compress=zstd,noatime "$ROOT" /mnt
mkdir -p /mnt/home /mnt/boot
mount -o subvol=@home,compress=zstd,noatime "$ROOT" /mnt/home
mount "$ESP" /mnt/boot

echo "==> debootstrap $DEBIAN_VERSION ($ARCH) from Tsinghua mirror"
debootstrap --arch="$ARCH" "$DEBIAN_VERSION" /mnt "$MIRROR"

echo "==> Writing /etc/fstab"
ROOT_UUID=$(blkid -s UUID -o value "$ROOT")
ESP_UUID=$(blkid -s UUID -o value "$ESP")
cat > /mnt/etc/fstab <<EOF
UUID=$ROOT_UUID /     btrfs subvol=@root,compress=zstd,noatime 0 0
UUID=$ROOT_UUID /home btrfs subvol=@home,compress=zstd,noatime 0 0
UUID=$ESP_UUID  /boot vfat  defaults,umask=0077                  0 2
EOF

echo "==> Bind-mounting /dev /proc /sys /run into /mnt"
for d in dev proc sys run; do mount --rbind "/$d" "/mnt/$d"; done

FIRMWARE_PKG=""
[[ "$INCLUDE_FIRMWARE" = yes ]] && FIRMWARE_PKG="firmware-linux firmware-linux-nonfree"

echo "==> Provisioning inside chroot"
cat > /mnt/tmp/provision.sh <<PROVISION
#!/bin/bash
set -euo pipefail

# Point apt at Tsinghua for the installed system too
cat > /etc/apt/sources.list.d/debian.sources <<'EOF'
Types: deb
URIs: $MIRROR
Suites: $DEBIAN_VERSION $DEBIAN_VERSION-updates $DEBIAN_VERSION-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: $SEC_MIRROR
Suites: $DEBIAN_VERSION-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  linux-image-$ARCH \
  systemd systemd-sysv dbus \
  grub-efi-$ARCH efibootmgr \
  btrfs-progs \
  locales tzdata \
  sudo \
  network-manager \
  openssh-server \
  ca-certificates curl gnupg git \
  $FIRMWARE_PKG

# hostname + hosts
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
::1       localhost ip6-localhost ip6-loopback
EOF
echo "127.0.1.1 $HOSTNAME" >> /etc/hosts

# timezone + locale
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
sed -i 's/# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# user bl with passwordless sudo
useradd -m -G sudo -s /bin/bash $USER_NAME
echo "$USER_NAME:$USER_PASS" | chpasswd
echo "root:$USER_PASS" | chpasswd
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME
chmod 440 /etc/sudoers.d/$USER_NAME

# GRUB-EFI: try NVRAM first, always write the removable fallback so the
# system boots even without persistent EFI vars (VMs, recycled hardware)
grub-install --target=$ARCH-efi --efi-directory=/boot --bootloader-id=debian 2>/dev/null || true
grub-install --target=$ARCH-efi --efi-directory=/boot --removable
update-grub

# services
systemctl enable NetworkManager
systemctl enable ssh

# Seed the df repo so setup.sh is ready on first login
cd /home/$USER_NAME
git clone $REPO_URL df 2>/dev/null || true
chown -R $USER_NAME:$USER_NAME df

apt-get clean
PROVISION

chmod +x /mnt/tmp/provision.sh
chroot /mnt /tmp/provision.sh
rm /mnt/tmp/provision.sh

echo "==> Unmounting"
for d in run sys proc dev; do
  umount -R "/mnt/$d" 2>/dev/null || umount "/mnt/$d" 2>/dev/null || true
done
umount /mnt/boot /mnt/home /mnt

cat <<EOF

========================================
Install complete.

1. Remove the install media
2. reboot
3. Log in as $USER_NAME / $USER_PASS
4. cd ~/df && bash debian/setup.sh     # dev toolchain
========================================
EOF
