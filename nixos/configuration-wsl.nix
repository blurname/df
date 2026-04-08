# WSL2 配置
{ config, pkgs, ... }:
{
  imports = [
    ./sub/common/base.nix
    ./sub/wsl/mod.nix
  ];
}
