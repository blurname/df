# 实体机配置（含 GUI）
{ config, pkgs, ... }:
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./sub/common/base.nix   # 基础系统配置
    ./sub/host/mod.nix      # 实体机模块（含 GUI）
  ];

  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };
}


