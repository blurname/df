{ config, pkgs, ... }:
{

	services.xserver = {
		#videoDrivers = [ "nvidia" ];
		enable = true;
		#displayManager = {
			#setupCommands = "qv2ray &\n ";
			#lightdm = {
				#enable = true;
				#background =/home/bl/wallpapers/vlcsnap-2021-04-11-00h08m46s220.png;
				##greeters={
					##tiny.label = {
						##user = "bl";
						##pass = "a";
					##};
				##};
			#};
		#};
		windowManager.leftwm.enable = true;
		# windowManager.xmonad={
		# 	enable = true;
		# 	extraPackages = haskellPackages: [
		# 		  haskellPackages.xmonad-contrib
		# 			haskellPackages.monad-logger
		# 	];
		# };
    libinput={
    enable = true;
      touchpad={
        middleEmulation = true;
        tapping =true;
        naturalScrolling = false;
      };
    };
	};
	# programs.neovim = {
	# 	enable = true;
	# 	defaultEditor = true;
	# 	configure = {
	# 		customRC = builtins.readFile /home/bl/.config/nvim/init.vim;
	# 		packages.myVimPackage = with pkgs.vimPlugins;{
	# 			start = [ packer-nvim ];
	# 		};
	# 	};
	# };
  programs.npm = {
    enable = true;
    npmrc =''
      prefix = /home/bl/.npm-global
      registry=https://registry.npmmirror.com/
      '';
  };

}

