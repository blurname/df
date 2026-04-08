# WSL2 模块
{ config, pkgs, ... }:
{
  imports = [
    ../common/cli.nix
    ../common/docker.nix
    ../common/editor.nix
    ../common/language.nix
    ../common/linux.nix
    ../vm/vscode-remote.nix
  ];

  nixpkgs.config.allowUnfree = true;

  wsl = {
    enable = true;
    defaultUser = "bl";
  };
}
