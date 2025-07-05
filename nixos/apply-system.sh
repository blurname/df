#/bin/sh
# sudo nixos-rebuild switch -I nixos-config=/home/bl/df/1-nixos/configuration.nix
sudo nixos-rebuild switch \
--flake './nixos#nyx' \
--impure \
--option substituters "https://mirrors.bfsu.edu.cn/nix-channels/store" \
#nixos-rebuild switch --flake '/home/bl/df/1-nixos#nyx' --impure --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
# sudo nixos-rebuild switch -I nixos-config=/home/bl/df/1-nixos/configuration.nix --upgrade 
