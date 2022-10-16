
{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking = {
    hostName = "nyx";
    firewall = {
      enable = false;
    };
    networkmanager = {
      enable = true;
    };
  };
  time.timeZone = "Asia/Shanghai";

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
  };
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };
  sound.enable = true;
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

  programs.sway.enable = true;
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    starship
    exa
    bat
    nodejs
    carapace
    alacritty
  ];

  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];


  # system.stateVersion = "unstable"; # Did you read the comment?
}
