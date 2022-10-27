{ config,pkgs,...}:
{
    environment.systemPackages = with pkgs; [
    waybar
    wofi
    rofi-wayland
    swaylock
    hyprpaper
    eww-wayland
  ];
  
  programs.sway.enable = true;
  programs.xwayland.enable = true;
}
