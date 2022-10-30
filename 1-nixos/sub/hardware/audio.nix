{pkgs,...}:
{
  
  sound.enable = true;
  #hardware.pulseaudio.enable = true;
  # pipewire cause firefox crashed

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nixpkgs.config.pulseaudio = true;
    environment.systemPackages = with pkgs; [
    # mcfly
    #xfce.xfce4-power-manager
    
    #
    #brightnessctl
    
    
    pamix
    ncpamixer
    pavucontrol
    pasystray
  ];
}
