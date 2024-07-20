{ config, pkgs, ... }:

{

  imports =
    [
    /etc/nixos/hardware-configuration.nix
      ./sub/mod.nix
#<home-manager/nixos>
    ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # nixpkgs.config.packageOverrides = pkgs: {
  #   nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
  #     inherit pkgs;
  #   };
  # };

# Set your time zone.
  time.timeZone = "Asia/Shanghai";

# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  users = {
    users.bl = {
      isNormalUser = true;
      extraGroups = [ "wheel" "bao" "docker" "audio" ]; # Enable ‘sudo’ for the user.
        password = "b"; # change user password: passwd bl
    };
    defaultUserShell = pkgs.bash;
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

  nix.settings = {
    substituters = [
    "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ];
  };
  system.stateVersion = "unstable";

}
