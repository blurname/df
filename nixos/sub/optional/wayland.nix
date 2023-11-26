{ config,pkgs,...}:
{
    environment.systemPackages = with pkgs; [
    waybar
    xdg-desktop-portal-hyprland
    wofi
    swaylock
    hyprpaper swaybg
    mako libsForQt5.polkit-kde-agent mate.mate-polkit polkit_gnome

    wl-clipboard cliphist
    # eww-wayland
  ];
  
  # programs.sway.enable = true;
  programs.xwayland.enable = true;
  programs.hyprland.enable = true; 
  #security.polkit.enable = true;

  security.pam.services.swaylock = {}; # https://github.com/NixOS/nixpkgs/issues/158025#issuecomment-1344766809 
}
