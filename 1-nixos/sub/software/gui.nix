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
      libsForQt5.dolphin-plugins
      libsForQt5.qt5ct
      tela-icon-theme
      syncthing
      fcitx5-gtk fcitx5-rime rime-data
      libsForQt5.fcitx5-qt
      pcmanfm
      trayer nm-tray syncthing-tray 
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    #fcitx5.enableRimeData = true;
    #fcitx.engines = with pkgs.fcitx-engines;[
      #rime
    #];
    fcitx5.addons = with pkgs;
    [
        fcitx5-chinese-addons
    ];
  };
}
