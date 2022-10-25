#/bin/sh
# sudo nixos-rebuild switch -I nixos-config=/home/bl/df/1-nixos/configuration.nix
sudo nixos-rebuild switch --flake '/home/bl/df/1-nixos#nyx' --impure 
# sudo nixos-rebuild switch -I nixos-config=/home/bl/df/1-nixos/configuration.nix --upgrade 
