{ config,pkgs,...}:
{
    environment.systemPackages = with pkgs; [
    waybar
    wofi
  ];
  
  programs.sway.enable = true;
}