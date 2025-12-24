# 通用模块 - host 和 vm 共用
{ config, pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
}

