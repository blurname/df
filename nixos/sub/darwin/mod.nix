# Darwin 模块 - macOS 专用（复用 common 模块）
{ config, pkgs, ... }:
{
  imports = [
    ../common/cli.nix
    ../common/editor.nix
    ../common/language.nix
  ];

  nixpkgs.config.allowUnfree = true;
}

