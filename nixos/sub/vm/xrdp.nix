# xrdp 远程桌面 - 轻量 GUI (xfce) + Hyper-V Enhanced Session
{ config, pkgs, ... }:
{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "dbus-run-session -- xfce4-session";
    openFirewall = true;
  };

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "bl";
  };

  virtualisation.hypervGuest.enable = true;

  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
  };

  environment.systemPackages = [
    pkgs.google-chrome
    pkgs.xorg.xinit
  ];
}
