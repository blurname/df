# 虚拟机配置（无 GUI）
{ config, pkgs, ... }:
{
  imports = [
    ./sub/common/base.nix   # 基础系统配置
    ./sub/vm/mod.nix        # 虚拟机模块（无 GUI）
  ]
  ++ (if builtins.pathExists /etc/nixos/hardware-configuration.nix
        then [ /etc/nixos/hardware-configuration.nix ] else [])
  ++ (if builtins.pathExists ./local.nix
        then [ ./local.nix ] else []);
}
