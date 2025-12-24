# 虚拟机配置（无 GUI）
{ config, pkgs, ... }:
{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./sub/common/base.nix   # 基础系统配置
    ./sub/vm/mod.nix        # 虚拟机模块（无 GUI）
  ];
}
