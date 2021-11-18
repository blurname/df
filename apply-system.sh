#/bin/sh
pushd ~/Nyx
sudo nixos-rebuild switch -I nixos-config=./system/configuration.nix
popd
