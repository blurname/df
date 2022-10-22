{ config,pkgs,...}:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./gui.nix
    ./language.nix
    ./wayland.nix
#    ./x11.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
}
