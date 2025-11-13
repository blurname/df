{ config,pkgs,...}:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
    # ./optional/x11.nix
    # ./optional/wayland.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
  services.xserver.enable = true; # optional
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
}
