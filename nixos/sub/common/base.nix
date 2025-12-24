# 基础系统配置 - host 和 vm 共用
{ config, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
      extraGroups = [ "wheel" "bao" "docker" "audio" ];
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

  nix.settings = {
    substituters = [
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ];
  };

  system.stateVersion = "25.11";
}

