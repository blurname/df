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
      #allProxy = "http://127.0.0.1:8889";
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
      passwordAuthentication = true;
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

#  nixpkgs.overlays = [
#    (import (builtins.fetchTarball {
#      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
#    }))
#  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    neovim
    git
    starship
    exa
    bat
    #alacritty
    ripgrep
    fd
    fzf
    gitui
    wget
    #picom
    #firefox
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
    # mcfly
    bottom
    htop
    gcc
    #rofi
    #qv2ray
    v2ray
    go
    #xorg.xmodmap
    #xfce.xfce4-power-manager
    feh
    xclip
    #tdesktop
    #google-chrome
    #brightnessctl
    eww
    neofetch
    #qbittorrent
    vlc
    #libsForQt5.kdeconnect-kde
    # xmobar
    # neovim-nightly
    haskell-language-server
    rnix-lsp
    sumneko-lua-language-server
    rust-analyzer
    #zathura
    #vscode
  ];


 # fonts.fonts = with pkgs;[
 #   source-han-serif
 # ] ++ [
 #   (nerdfonts.override { fonts = [ "Iosevka" ]; })
 # ];
  #virtualisation.docker.enable = true;
  #services.picom.inactiveOpacity = 0.7;
  #services.picom.opacityRules = [
  #"60:class_g = 'Alacritty'"
  #];
  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  system.stateVersion = "unstable"; # Did you read the comment?

}
