# xrdp 远程桌面 - 轻量 GUI (openbox)
{ config, pkgs, ... }:
{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "openbox-session";
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    openbox
    xterm  # 右键菜单可开终端
  ];
}
