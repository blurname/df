#!/bin/bash -ex
#########################################################################
# File Name: install.sh
# Author: nian
# Blog: https://whoisnian.com
# Mail: zhuchangbao1998@gmail.com
# Created Time: 2020-07-31 00:15:50
#########################################################################

###########################
### need check manually ###
########## start ##########
I_DRIVE_MAIN='/dev/nvme0n1'
I_HOSTNAME='lsy'
I_ROOT_PASS='dsg'
I_USER_NAME='bl'
I_USER_PASS='a'
########### end ###########

I_SCRIPT_FILE="$0"
I_TIMEZONE='Asia/Shanghai'
I_BOOT_MODE='bios'
if [[ -d '/sys/firmware/efi/efivars/' ]]; then
    I_BOOT_MODE='uefi'
fi
get_drive() { echo $(lsblk -lnpo NAME,MAJ:MIN $I_DRIVE_MAIN | grep -Po "$I_DRIVE_MAIN\S*$1(?=\s)"); }
drive_boot() { if [[ $I_BOOT_MODE == 'uefi' ]]; then get_drive 1; fi; }
drive_root() { if [[ $I_BOOT_MODE == 'uefi' ]]; then get_drive 2; else get_drive 1; fi; }
drive_swap() { if [[ $I_BOOT_MODE == 'uefi' ]]; then get_drive 3; else get_drive 2; fi; }

color() {
    case $1 in
    green) echo -e "\033[32m$2\033[0m" ;;
    red) echo -e "\033[31m$2\033[0m" ;;
    yellow) echo -e "\033[33m$2\033[0m" ;;
    esac
}

setup() {
    prepare_for_setup
    setup_partition
    setup_format_partitions
    setup_mount_filesystems
    specify_archlinux_mirror
    setup_install_base
    setup_set_fstab
    prepare_for_configure
    setup_unmount_filesystems

    color green '>>> Done! Please reboot system'
}

configure() {
    specify_archlinux_mirror
    configure_set_timezone
    configure_set_locale
    configure_set_hostname
    configure_set_hosts
    configure_set_root_pass
    configure_set_bootloader
    configure_create_user
    configure_set_archlinuxcn
    # configure_install_dotfiles
    configure_set_sudoers
}
software(){
    configure_install_custom
    install_aur_packages
    df
    config_service
    configure_clean_packages
}

df(){
  cd /home/bl
  git clone https://github.com/blurname/df.git
  bash /home/bl/df/script/001-link-config.sh
  bash /home/bl/df/script/002-npmchore.sh
  cd /home/bl/.config
  git clone https://github.com/blurname/nvim.git
}

specify_archlinux_mirror() {
    color green '>>> Specifying archlinux mirror'

    echo 'Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
# Server = http://mirror.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    pacman -Syy archlinux-keyring --noconfirm
}

prepare_for_setup() {
    color green '>>> Prepareing for setup'

    timedatectl set-ntp true
}

setup_partition() {
    color green ">>> Creating partitions on '$I_DRIVE_MAIN'"

    if [[ $I_BOOT_MODE == 'uefi' ]]; then
        (
            echo g # new GPT partition table
            echo n # first partition for '/boot'
            echo 1
            echo
            echo +512M
            echo n # second partition for '/'
            echo 2
            echo
            echo -8G
            echo n # third partition for swap
            echo 3
            echo
            echo
            echo t # partition type 'EFI System'
            echo 1
            echo 1
            echo t # partition type 'Linux root (x86-64)'
            echo 2
            echo 23
            echo t # partition type 'Linux swap'
            echo 3
            echo 19
            echo p # show result
            echo w # save
        ) | fdisk $I_DRIVE_MAIN
    else
        (
            echo o # new DOS partition table
            echo n # first partition for '/'
            echo p
            echo 1
            echo
            echo -8G
            echo n # second partition for swap
            echo p
            echo 2
            echo
            echo
            echo a # set bootable flag
            echo 1
            echo t # partition type 'Linux swap'
            echo 2
            echo 82
            echo p    # show result
            sleep 0.1 # FIX: Re-reading the partition table failed.
            echo w    # save
        ) | fdisk $I_DRIVE_MAIN
    fi
}

setup_format_partitions() {
    color green '>>> Formatting the partitions'

    if [[ $I_BOOT_MODE == 'uefi' ]]; then
        mkfs.fat -F32 $(drive_boot)
        mkfs.ext4 -F $(drive_root)
        mkswap $(drive_swap)
    else
        mkfs.ext4 -F $(drive_root)
        mkswap $(drive_swap)
    fi
}

setup_mount_filesystems() {
    color green '>>> Mounting the filesystems'

    if [[ $I_BOOT_MODE == 'uefi' ]]; then
        mount $(drive_root) /mnt
        mkdir /mnt/boot
        mount $(drive_boot) /mnt/boot
        swapon $(drive_swap)
    else
        mount $(drive_root) /mnt
        swapon $(drive_swap)
    fi
}

setup_unmount_filesystems() {
    color green '>>> Unmounting filesystems'

    umount -R /mnt
    swapoff $(drive_swap)
}

setup_install_base() {
    color green '>>> Installing base system'

    pacstrap /mnt base base-devel linux linux-firmware vim
}

# note: boot partion's uuid is wrong, use blkid to get the right, and modify it in /etc/fstab
setup_set_fstab() {
    color green '>>> Setting fstab'

    genfstab -U /mnt >>/mnt/etc/fstab
}

prepare_for_configure() {
    color green '>>> Chrooting into installed system'

    cp $I_SCRIPT_FILE /mnt/install.sh
    arch-chroot /mnt /bin/bash -ex /install.sh configure
    rm /mnt/install.sh
}

configure_set_timezone() {
    color green '>>> Setting timezone'

    ln -sf "/usr/share/zoneinfo/$I_TIMEZONE" /etc/localtime
    hwclock --systohc --utc
    timedatectl set-ntp true
}

configure_set_locale() {
    color green '>>> Setting locale'

    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
    echo 'LANG=en_US.UTF-8' >/etc/locale.conf
    locale-gen
}

configure_set_hostname() {
    color green '>>> Setting hostname'

    echo "$I_HOSTNAME" >/etc/hostname
}

configure_set_hosts() {
    color green '>>> Setting hosts file'

    cat >/etc/hosts <<EOF
127.0.0.1   localhost.localdomain localhost
::1         localhost.localdomain localhost
EOF
}

configure_set_root_pass() {
    color green '>>> Setting root password'

    (
        echo "$I_ROOT_PASS"
        echo "$I_ROOT_PASS"
    ) | passwd
}

configure_set_bootloader() {
    color green '>>> Configuring bootloader'

    local ucode=''
    if [[ $(grep -m 1 'vendor_id' /proc/cpuinfo) =~ 'Intel' ]]; then
        ucode='intel-ucode'
    elif [[ $(grep -m 1 'vendor_id' /proc/cpuinfo) =~ 'AMD' ]]; then
        ucode='amd-ucode'
    fi

    if [[ $I_BOOT_MODE == 'uefi' ]]; then
        pacman -S --noconfirm $ucode
        bootctl --path=/boot install
        root_partuuid=$(sudo blkid -s PARTUUID -o value $(drive_root))
        cat >/boot/loader/loader.conf <<EOF
default arch.conf
#timeout 3
console-mode max
editor no
EOF
        cat >/boot/loader/entries/arch.conf <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /$ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=$root_partuuid rw
EOF
        cat >/boot/loader/entries/arch-fallback.conf <<EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /$ucode.img
initrd  /initramfs-linux-fallback.img
options root=PARTUUID=$root_partuuid rw
EOF
        mkdir -p /etc/pacman.d/hooks/
        cat >/etc/pacman.d/hooks/100-systemd-boot.hook <<EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Gracefully upgrading systemd-boot...
When = PostTransaction
Exec = /usr/bin/systemctl restart systemd-boot-update.service
EOF
    else
        pacman -S --noconfirm grub $ucode
        grub-install --target=i386-pc $I_DRIVE_MAIN
        sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /boot/grub/grub.cfg
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
}

configure_set_archlinuxcn() {
    color green '>>> Setting archlinuxcn repo'

    sed -i 's/#Color/Color/g' /etc/pacman.conf
    echo '[archlinuxcn]
    Server = http://mirrors.ustc.edu.cn/archlinuxcn/$arch' >>/etc/pacman.conf
    pacman -Sy --noconfirm archlinuxcn-keyring
}

configure_install_custom() {
    color green '>>> Installing custom packages'

    local packages=''

    packages+=' xorg networkmanager'
    # systemctl enable sddm
    # Programming languages
    packages+=' rustup nodejs go'
 
    # Network tools
    packages+=' crda dnsmasq bind net-tools inetutils traceroute nmap openbsd-netcat axel wget clash privoxy proxychains-ng v2ray v2raya'

    # Management and monitoring
    packages+=' htop iftop lsof neofetch stress arch-install-scripts'

    # Other CLI tools
    packages+=' git paru pikaur rsync jq tree kdialog p7zip unarchiver unzip openssh frpc man-pages strace ripgrep exa bat '

    # KDE applications
    packages+=' dolphin kate gwenview spectacle kdeconnect kcalc kmix'

    # Common applications
    packages+=' vim peek vlc gimp obs-studio keepassxc syncthing picom xfce4-power-manager network-manager-applet feh'

    # Web browsers
    packages+=' chromium firefox'

    # Input method and fonts
    # packages+=' fcitx5-im fcitx5-chinese-addons fcitx5-pinyin-zhwiki ttf-ubuntu-font-family noto-fonts-cjk noto-fonts-emoji wqy-microhei'

    pacman -S --noconfirm $packages
}

install_aur_packages(){
    color green '>>> Installing aur packages'

    local packages=''

    # shell
    packages+=' carapace-bin starship '
    # nvim
    packages+=' neovim-git python-pynvim nvim-packer-git'

    # sway
    packages+=' sway waybar bemenu-wayland swaybg wofi'

    # bluetooth
    packages+=' blueman pulseaudio-bluetooth'

    # app
    packages+=' logseq-desktop-bin visual-studio-code-bin lazygit'

    # Input method 
    packages+=' fcitx5-im fcitx5-rime rime-double-pinyin'

    # font
    packages +=' adobe-source-han-serif-cn-fonts nerd-fonts-complete ttf-iosevka'


    paru -S --noconfirm $packages
}

configure_clean_packages() {
    color green '>>> Clearing packages cache'

    pacman -Scc --noconfirm
}

configure_create_user() {
    color green '>>> Creating initial user'

    pacman -S --noconfirm elvish sudo
    useradd -m -k '' -G wheel -s /bin/elvish "$I_USER_NAME"
    (
        echo "$I_USER_PASS"
        echo "$I_USER_PASS"
    ) | passwd "$I_USER_NAME"
    gpasswd -a 'bl' docker
    gpasswd -a 'bl' audio
}

configure_set_sudoers() {
    color green '>>> Configuring sudo'

    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers
    echo "${I_USER_NAME} ALL=(ALL) NOPASSWD:ALL" | sudo SUDO_EDITOR='tee -a' visudo
}
config_service() {
  systemctl enable v2raya
  systemctl enable bluetooth
  systemctl enable NetworkManager
}

if [[ "$1" == 'setup' ]]; then
    setup
elif [[ "$1" == 'configure' ]]; then
    configure
elif [[ "$1" == 'software' ]]; then
    software
fi
