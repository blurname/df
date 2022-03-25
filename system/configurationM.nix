
{ config, pkgs, ... }:

{

  imports =
    [
      ./hardware-configuration.nix
    ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      			experimental-features = nix-command flakes
      			'';
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking = {
    hostName = "nyx";
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

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    starship
    exa
    bat
  ];

  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  networking.firewall.enable = false;

  system.stateVersion = "unstable"; # Did you read the comment?
}
