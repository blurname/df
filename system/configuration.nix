# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

	imports =
		[
		/etc/nixos/hardware-configuration.nix
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
		proxy ={
			allProxy="http://127.0.0.1:8889";
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
		passwordAuthentication = false;
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
	services.xserver = {
		enable = true;
		windowManager.leftwm.enable = true;
	};

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
	users={
		users.bl = {
			isNormalUser = true;
			extraGroups = [ "wheel" "bao" ]; # Enable ‘sudo’ for the user.
				password = "a";
			openssh.authorizedKeys.keys=[
				"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlstol98Hft8h6d6LKTjgaczPvA3uwIWp3cGHMaHij42ivAJQhLurN0yUO34D3Tnw65I9IibKeOJ9UbH301yZOlX/Q5KqzbyyjuBotsyyzH4FQicGVnHNLr3pWq3d9Inhr8Hk862bBb96ts9zranlIcXOFPyCnAexlZpV7QAGG19K9BdQLUIFifADlNGUc9Fq9knR2TZ+l7VLbkVT2eASGMGpsqoxBV3QurKdNGj/gGLNM5jAHp77rLhKPnimBmYJoyzovOCLa7EGBA3AK4eiKbgH0PP5cIj0ccNvbbFrI/miVjJ4yckHWBeZPQoBh83zbuoLGdrsigqkXmANiHeFeKBUqLHGgzB/L60S0UNJ1pfoLSFwWYsEcKfdNPnr+F1glPzUM4eBb8O1TlgTFioNSYoibI5FHoE1BgWaXYyJiD8qhG7zrMtDFM1gBan9dANEsfqahWp2paaD/aJQdJz8WZKOEhKC1u50jOg4yRoJUhW2eDBBUKT9mvu0SA7e49ws= bl@DESKTOP-TDF969O"
			];
		};
		defaultUserShell = pkgs.elvish;
		extraUsers.bl.extraGroups = ["audio"];
	};
	security.sudo.extraRules = [
	{
		users = ["bl"];
		commands =[{
			command = "ALL";
			options =["SETENV" "NOPASSWD"];
		}
		];
	}];
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
			rnix-lsp
			nixpkgs-fmt
			zellij
			curl
			sl
			unzip
			sumneko-lua-language-server
			rust-analyzer
			mcfly
			bottom
			htop
			gcc
			iosevka
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
#nerdfonts
			];

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		configure = {
			customRC = builtins.readFile /home/bl/.config/nvim/init.vim;
			packages.myVimPackage = with pkgs.vimPlugins;{
				start = [ packer-nvim ];
			};
		};
	};

	services.picom.inactiveOpacity = 0.7;
	services.picom.opacityRules = [
		"60:class_g = 'Alacritty'"
	];
	nix.binaryCaches = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" "https://mirrors.ustc.edu.cn/nix-channels/store" "https://mirror.sjtu.edu.cn/nix-channels/store" ];


	networking.firewall.enable = false;

	system.stateVersion = "unstable"; # Did you read the comment?

}
