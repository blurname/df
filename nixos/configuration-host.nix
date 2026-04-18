# 实体机配置（含 GUI）
{ config, pkgs, ... }:
{
  imports = [
    ./sub/common/base.nix   # 基础系统配置
    ./sub/host/mod.nix      # 实体机模块（含 GUI）
  ]
  ++ (if builtins.pathExists /etc/nixos/hardware-configuration.nix
        then [ /etc/nixos/hardware-configuration.nix ] else [])
  ++ (if builtins.pathExists ./local.nix
        then [ ./local.nix ] else []);
}


