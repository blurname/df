{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    tdesktop
    qbittorrent
    vlc
    libsForQt5.kdeconnect-kde
    firefox
    google-chrome
  ];
}