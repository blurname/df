# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ./programs.nix
      #<home-manager/nixos>
    ];
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      			experimental-features = nix-command flakes
      			'';
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "/dev/disk/by-uuid/469E-24BF";

  #networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking = {
    hostName = "nyx";
    proxy = {
      allProxy = "http://127.0.0.1:8889";
      #httpsProxy="http://127.0.0.1:8889";
    };
    #    interfaces={
    #    enp0s3.ip4=[{
    #      address = "192.168.1.2";
    #      prefixLength = 28;
    #    }];
    #    };
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = false;
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
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = true;
  #networking.interfaces.enp0s3.useDHCP = true;
  services = {
    #mysql={enable = true;package = pkgs.mariadb;};
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.
  #hardware.nvidia.prime = {
    #sync.enable = true;
    #nvidiaBusId = "PCI:1:0:0";
    #intelBusId = "PCI:0:2:0";
  #};

  # Configure keymap in X11
  #services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  #hardware.pulseaudio.enable = true;
  #home-manager.users.bl ={pkgs,...}:{
  #  home.pacages = with pkgs;[
  #    atool httpie
  #  ];
  #  programs.bash.enable = true;
  #programs.git.userName ="blurname";
  #programs.git.userEmail ="naughtybao@outlook.com";
  #};




  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.bl = {
      isNormalUser = true;
      extraGroups = [ "wheel" "bao" "docker" "audio" ]; # Enable ‘sudo’ for the user.
      password = "a";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlstol98Hft8h6d6LKTjgaczPvA3uwIWp3cGHMaHij42ivAJQhLurN0yUO34D3Tnw65I9IibKeOJ9UbH301yZOlX/Q5KqzbyyjuBotsyyzH4FQicGVnHNLr3pWq3d9Inhr8Hk862bBb96ts9zranlIcXOFPyCnAexlZpV7QAGG19K9BdQLUIFifADlNGUc9Fq9knR2TZ+l7VLbkVT2eASGMGpsqoxBV3QurKdNGj/gGLNM5jAHp77rLhKPnimBmYJoyzovOCLa7EGBA3AK4eiKbgH0PP5cIj0ccNvbbFrI/miVjJ4yckHWBeZPQoBh83zbuoLGdrsigqkXmANiHeFeKBUqLHGgzB/L60S0UNJ1pfoLSFwWYsEcKfdNPnr+F1glPzUM4eBb8O1TlgTFioNSYoibI5FHoE1BgWaXYyJiD8qhG7zrMtDFM1gBan9dANEsfqahWp2paaD/aJQdJz8WZKOEhKC1u50jOg4yRoJUhW2eDBBUKT9mvu0SA7e49ws= bl@DESKTOP-TDF969O"
      ];
    };
    defaultUserShell = pkgs.elvish;
    #extraUsers.bl.extraGroups = ["audio"];
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

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    starship
    exa
    bat
    alacritty
    ripgrep
    fd
    fzf
    starship
    gitui
    wget
    picom
    firefox
    zsh
    rustup
    python39
    nodejs-16_x
    yarn
    nixpkgs-fmt
    zellij
    curl
    sl
    unzip
    mcfly
    bottom
    htop
    gcc
    rofi
    qv2ray
    v2ray
    go
    xorg.xmodmap
    xfce.xfce4-power-manager
    feh
    xclip
    tdesktop
    google-chrome
    brightnessctl
    eww
    neofetch
    qbittorrent
    vlc
    libsForQt5.kdeconnect-kde
    xmobar
    neovim-nightly
    haskell-language-server
    rnix-lsp
    sumneko-lua-language-server
    rust-analyzer
    zathura
    vscode
  ];


  fonts.fonts = with pkgs;[
    source-han-serif
  ] ++ [
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];
  virtualisation.docker.enable = true;
  #services.picom.inactiveOpacity = 0.7;
  #services.picom.opacityRules = [
  #"60:class_g = 'Alacritty'"
  #];
  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  system.stateVersion = "unstable"; # Did you read the comment?

}
