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
      libsForQt5.qt5ct
      syncthing
      fcitx5-gtk fcitx5-rime rime-data
      libsForQt5.fcitx5-qt
      pcmanfm
      trayer nm-tray syncthingtray 
      gns3-gui gns3-server
      wl-clipboard cliphist
      bemenu
      bleachbit
      android-file-transfer
      microsoft-edge
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
  #services = {
    #syncthing = {
      #enable = true;
      #user = "bl";
##dataDir = "/home/myusername/Documents";    # Default folder for new synced folders
##configDir = "/home/myusername/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
    #};
  #};
}
