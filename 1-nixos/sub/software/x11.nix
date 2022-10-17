{ config,pkgs,...}:
{
  #hardware.nvidia.prime = {
    #sync.enable = true;
    #nvidiaBusId = "PCI:1:0:0";
    #intelBusId = "PCI:0:2:0";
  #};
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager.leftwm.enable = true;
    #videoDrivers = [ "nvidia" ];
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
  };
    environment.systemPackages = with pkgs; [
    rofi
    xclip
    eww
    picom
  ];
  
}