# 服务器配置 - 无 GUI + btrfs 快照回滚 impermanence
{ config, pkgs, ... }:
{
  imports = [
    ./sub/common/base.nix
    ./sub/server/mod.nix
  ]
  ++ (if builtins.pathExists /etc/nixos/hardware-configuration.nix
        then [ /etc/nixos/hardware-configuration.nix ] else [])
  ++ (if builtins.pathExists ./local.nix
        then [ ./local.nix ] else []);
}
