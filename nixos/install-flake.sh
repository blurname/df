# 安装 NixOS，设置 substituters 选项为 "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
nixos-install --flake '/home/nixos/df/nixos#nyx' --impure --option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store"
echo y
echo y
echo y
echo y

echo b
echo b
cp -r /home/nixos/df /mnt/etc/bl/
