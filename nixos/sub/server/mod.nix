# 服务器聚合模块 - 无 GUI，带 impermanence
{ config, pkgs, ... }:
{
  imports = [
    ../common/boot.nix
    ../common/cli.nix
    ../common/docker.nix
    ../common/editor.nix
    ../common/language.nix
    ../common/linux.nix
    ./network.nix
    ./disko.nix
    ./impermanence.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
}
