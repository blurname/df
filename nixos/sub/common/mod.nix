# 通用模块 - host 和 vm 共用 (NixOS)
{ config, pkgs, ... }:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
    ./linux.nix  # NixOS 特有配置
  ];

  nixpkgs.config.allowUnfree = true;
}

