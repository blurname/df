{ config,pkgs,...}:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
    ./optional/minigui.nix
    # ./optional/x11.nix
    ./optional/wayland.nix
    ./optional/font.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
}
