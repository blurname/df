{ config, pkgs, ... }:

{

  imports =
    [
    /etc/nixos/hardware-configuration.nix
      ./sub/software/mod.nix
      ./sub/hardware/mod.nix
#<home-manager/nixos>
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

# Set your time zone.
  time.timeZone = "Asia/Shanghai";

# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

#home-manager.users.bl ={pkgs,...}:{
#  home.pacages = with pkgs;[
#    atool httpie
#  ];
#  programs.bash.enable = true;
#programs.git.userName ="blurname";
#programs.git.userEmail ="naughtybao@outlook.com";
#};

  users = {
    users.bl = {
      isNormalUser = true;
      extraGroups = [ "wheel" "bao" "docker" "audio" ]; # Enable ‘sudo’ for the user.
        password = "b"; # change user password: passwd bl
    };
    defaultUserShell = pkgs.elvish;
  };
  security.sudo.extraRules = [
  {
    users = [ "bl" ];
    commands = [{
      command = "ALL";
      options = [ "SETENV" "NOPASSWD" ];
    }];
  }
  ];
  fonts.fonts = with pkgs;[
    #source-han-serif
      #inconsolata-nerdfont
      lxgw-wenkai
      iosevka
  ];

  nix.settings = {
    substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    #"https://hyprland.cachix.org"
    "https://cache.nixos.org"
    ];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  system.stateVersion = "unstable";

}
