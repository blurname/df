#!/bin/bash

parted /dev/nvme0n1 -- mklabel gpt

# Create a primary partition starting at 512MiB and ending at the end of the device
parted /dev/nvme0n1 -- mkpart primary 512MiB 100%

# Create an ESP partition starting at 1MiB and ending at 512MiB
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 512MiB

# Set the second partition as the EFI System Partition
parted /dev/nvme0n1 -- set 2 esp on

# Create an Ext4 file system with the label "nixos" on the first partition
mkfs.ext4 -L nixos /dev/nvme0n1p1

# Create a FAT32 file system with the label "boot" on the second partition
mkfs.fat -F 32 -n boot /dev/nvme0n1p2

# Mount the partition with the "nixos" label to /mnt
mount /dev/disk/by-label/nixos /mnt

# Create the /mnt/boot directory
mkdir -p /mnt/boot

# Mount the partition with the "boot" label to /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Generate a NixOS configuration file for the system mounted at /mnt
nixos-generate-config --root /mnt

mv -f ./mini-configuration.nix /mnt/etc/nixos/configuration.nix

nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
