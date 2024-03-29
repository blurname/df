# 检查 nvme0n1 设备是否存在
if [[ -b /dev/nvme0n1 ]]; then
  device="/dev/nvme0n1"
  partition_prefix="p"
else
  device="/dev/sda"
  partition_prefix=""
fi

# 创建 GPT 标签的主分区
parted "$device" -- mklabel gpt

# 在设备末尾创建主分区，起始位置为 512MiB
parted "$device" -- mkpart primary 512MiB 100%

# 在 1MiB 和 512MiB 之间创建 ESP 分区
parted "$device" -- mkpart ESP fat32 1MiB 512MiB

# 将第二个分区设为 EFI 系统分区
parted "$device" -- set 2 esp on

# 在第一个分区上创建带有 "nixos" 标签的 Ext4 文件系统
mkfs.ext4 -L nixos "${device}${partition_prefix}1"

# 在第二个分区上创建带有 "boot" 标签的 FAT32 文件系统
mkfs.fat -F 32 -n boot "${device}${partition_prefix}2"

# 将带有 "nixos" 标签的分区挂载到 /mnt
mount /dev/disk/by-label/nixos /mnt

# 创建 /mnt/boot 目录
mkdir -p /mnt/boot

# 将带有 "boot" 标签的分区挂载到 /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# 为挂载在 /mnt 的系统生成 NixOS 配置文件
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /etc/nixos
bash ./install-flake.sh
