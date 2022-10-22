{ config,pkgs,...}:
{
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
    tdesktop
    qbittorrent
    vlc
    libsForQt5.kdeconnect-kde
    firefox
    google-chrome
    obsidian
    libsForQt5.dolphin
    libsForQt5.qt5ct
    tela-icon-theme
  ];
}