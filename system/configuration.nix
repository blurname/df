# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking = {
    hostName = "nixos";
    useDHCP = true;
    #    interfaces={
    #    enp0s3.ip4=[{
    #      address = "192.168.1.2";
    #      prefixLength = 28;
    #    }];
    #    };
  };
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.useDHCP = true;
  #networking.interfaces.enp0s3.useDHCP = true;
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  #services.xserver.windowManager.leftwm.enable = true;

  # Configure keymap in X11
  #services.xserver.layout = "us";

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;
  #   home-manager.users.bl ={pkgs,...}:{
  #  home.pacages = with pkgs;[
  #    atool httpie
  #  ];
  #  programs.bash.enable = true;
  #};


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.bl = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    password = "a";
  };
  users.defaultUserShell = pkgs.elvish;
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
    gcc
    gitui
    wget
    picom
    firefox
    zsh
    elvish
    rustup
    python39
    nodejs-16_x
    yarn
    rnix-lsp
    nixpkgs-fmt
    zellij
		curl
		sl
		lua
		luajit
		unzip
		sumneko-lua-language-server
		rust-analyzer
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = builtins.readFile "/home/bl/.config/nvim/init.vim";
      packages.myVimPackage = with pkgs.vimPlugins;{
        start = [ packer-nvim ];
      };
    };
  };

  #services.picom.inactiveOpacity = 0.7;
  #services.picom.opacityRules = [
  #  "100:class_g = 'Alacritty'"
  #];
  nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "unstable"; # Did you read the comment?

}
