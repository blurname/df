{ config, pkgs, ... }:

{

  imports =
    [
      /etc/nixos/hardware-configuration.nix
      #./programs.nix
      #<home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nyx";
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
    openssh = {
      enable = true;
      passwordAuthentication = true;
    };
  };


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #hardware.nvidia.prime = {
    #sync.enable = true;
    #nvidiaBusId = "PCI:1:0:0";
    #intelBusId = "PCI:0:2:0";
  #};

  # Configure keymap in X11
  #services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
  #hardware.pulseaudio.enable = true;
  #home-manager.users.bl ={pkgs,...}:{
  #  home.pacages = with pkgs;[
  #    atool httpie
  #  ];
  #  programs.bash.enable = true;
  #programs.git.userName ="blurname";
  #programs.git.userEmail ="naughtybao@outlook.com";
  #};


  programs.sway.enable = true;


  # Define a user account. Don't forget to set a password with ‘passwd’.
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
    alacritty
    ripgrep
    fd
    fzf
    gitui
    wget
    #picom
    firefox
    zsh
    rustup
    python39
    nodejs
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
    v2ray
    go
    #xfce.xfce4-power-manager
    feh
    xclip
    
    tdesktop
    #google-chrome
    #brightnessctl
    eww
    neofetch
    qbittorrent
    vlc
    libsForQt5.kdeconnect-kde
    libsForQt5.kmix
    # neovim-nightly
    haskell-language-server
    rnix-lsp
    sumneko-lua-language-server
    rust-analyzer
    waybar
    wofi
    vscode
    carapace
    pamix
  ];


  fonts.fonts = with pkgs;[
    source-han-serif
    iosevka
  ];
  virtualisation.docker.enable = true;
  nix.settings.substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  system.stateVersion = "unstable"; # Did you read the comment?

}
