{ config,pkgs,...}:
{
    environment.systemPackages = with pkgs; [
    waybar
    wofi
    rofi-wayland
    swaylock
    hyprpaper swaybg
    eww-wayland
  ];
  
  programs.sway.enable = true;
  programs.xwayland.enable = true;
}
