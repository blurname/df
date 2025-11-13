{ config,pkgs,...}:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
    ./optional/x11.nix
    ./optional/wayland.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
}
