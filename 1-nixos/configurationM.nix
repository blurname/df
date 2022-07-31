
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
    firewall = {
      enable = false;
    };
    networkmanager = {
      enable = true;
    };
    hosts = {
      "140.82.112.22" = [ "central.github.com" ];
      "140.82.112.4" = [ "gist.github.com" ];
      "140.82.113.26" = [ "live.github.com" ];
      "140.82.113.5" = [ "api.github.com" ];
      "140.82.114.25" = [ "alive.github.com" ];
      "140.82.114.3" = [ "github.com" ];
      "140.82.114.9" = [ "codeload.github.com" ];
      "185.199.108.133" = [
        "desktop.githubusercontent.com"
        "camo.githubusercontent.com"
        "github.map.fastly.net"
        "raw.githubusercontent.com"
        "user-images.githubusercontent.com"
        "favicons.githubusercontent.com"
        "avatars5.githubusercontent.com"
        "avatars4.githubusercontent.com"
        "avatars3.githubusercontent.com"
        "avatars2.githubusercontent.com"
        "avatars1.githubusercontent.com"
        "avatars0.githubusercontent.com"
        "avatars.githubusercontent.com"
        "media.githubusercontent.com"
        "cloud.githubusercontent.com"
        "objects.githubusercontent.com"
      ];
      "185.199.108.153" = [
        "assets-cdn.github.com"
        "github.io"
        "githubstatus.com"
      ];
      "185.199.108.154" = [ "github.githubassets.com" ];
      "192.0.66.2" = [ "github.blog" ];
      "199.232.69.194" = [ "github.global.ssl.fastly.net" ];
      "23.100.27.125" = [ "github.dev" ];
      "52.216.96.19" = [ "github-production-user-asset-6210df.s3.amazonaws.com" ];
      "52.217.1.148" = [ "github-com.s3.amazonaws.com" ];
      "52.217.141.105" = [ "github-production-repository-file-5c1aeb.s3.amazonaws.com" ];
      "52.217.90.252" = [ "github-production-release-asset-2e65be.s3.amazonaws.com" ];
      "54.231.193.73" = [ "github-cloud.s3.amazonaws.com" ];
      "64.71.144.202" = [ "github.community" ];
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


  system.stateVersion = "unstable"; # Did you read the comment?
}
