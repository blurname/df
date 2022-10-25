{ config,pkgs,...}:
{
    environment.systemPackages = with pkgs; [
    waybar
    wofi
    rofi-wayland
    swaylock
  ];
  
  programs.sway.enable = true;
  programs.xwayland.enable = true;
}
