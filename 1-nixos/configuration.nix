{ config, pkgs, ... }:

{

  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ./sub/software/mod.nix
      ./sub/hardware/mod.nix
      #<home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
      password = "a";
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
    source-han-serif
    inconsolata-nerdfont
  ];

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  system.stateVersion = "unstable";

}
