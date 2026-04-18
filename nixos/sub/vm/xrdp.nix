# xrdp 远程桌面 - i3 (替代之前的 xfce4) + Hyper-V Enhanced Session
{ config, pkgs, ... }:
{
  services.xrdp = {
    enable = true;
    # dbus-run-session 包一层让 i3 里 GTK 通知/字体正常
    defaultWindowManager = "dbus-run-session -- i3";
    openFirewall = true;
  };

  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.startx.enable = true;   # 允许 TTY 里 xinit/startx
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
    pkgs.rofi   # i3 launcher（比默认 dmenu 顺手）
    pkgs.alacritty
  ];
}
