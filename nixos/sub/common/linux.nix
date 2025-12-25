# NixOS 特有配置 - 仅 Linux
{ config, pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    # package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  services.v2raya.enable = true;
}

