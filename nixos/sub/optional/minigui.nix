{ config,pkgs,...}:
{
  # services.flatpak.enable = true;
  # https://github.com/NixOS/nixpkgs/issues/119433#issuecomment-986158837
  #fonts.fontDir.enable = true;
  #ln -s /run/current-system/sw/share/X11/fonts ~/.local/share/fonts
  #flatpak install flatseal
  #fonts.fontDir.enable = true;
  #services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
      firefox
      google-chrome
      bluez libsForQt5.bluez-qt libsForQt5.bluedevil # 蓝牙
      libsForQt5.dolphin libsForQt5.kdegraphics-thumbnailers libsForQt5.ark
      unrar
      flameshot
      hyprcursor
      nwg-look
      rose-pine-hyprcursor
      fuzzel
      xwayland-satellite
  ];

  i18n.inputMethod = {
    enabled = "fcitx5";
    #fcitx5.enableRimeData = true;
    fcitx5.addons = with pkgs;
    [
        fcitx5-chinese-addons
    ];
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  #services = {
    #syncthing = {
      #enable = true;
      #user = "bl";
##dataDir = "/home/myusername/Documents";    # Default folder for new synced folders
##configDir = "/home/myusername/Documents/.config/syncthing";   # Folder for Syncthing's settings and keys
    #};
  #};
}

