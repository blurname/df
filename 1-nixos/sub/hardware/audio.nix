{pkgs,...}:
{
  
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
    environment.systemPackages = with pkgs; [
    # mcfly
    #xfce.xfce4-power-manager
    
    #
    #brightnessctl
    
    
    pamix
    ncpamixer
  ];
}