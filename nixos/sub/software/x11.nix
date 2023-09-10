{ config,pkgs,lib,...}:
{
  #hardware.nvidia.prime = {
    #sync.enable = true;
    #nvidiaBusId = "PCI:1:0:0";
    #intelBusId = "PCI:0:2:0";
  #};
  #boot.kernelParams = ["module_blacklist=i915"];
# boot = {
# extraModprobeConfig = "options nvidia-drm modeset=1";
# };
  #hardware.nvidia = {
    #modesetting.enable = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
  #};
    environment.systemPackages = with pkgs; [
 #   dmenu
 #   st
    # eww-wayland
    xclip
  ];
  services.xserver = {
    #videoDrivers = [ "nvidia" ];
    enable = true;
    #windowManager.dwm.enable = true;
    #windowManager.leftwm.enable = true;
    #windowManager.icewm.enable = true;
    #displayManager.startx.enable = true;
    # displayManager.sddm.enable = true;
    # desktopManager.plasma5.enable = true;
#displayManager.gdm.enable = true;
#desktopManager.gnome.enable = true;
  };
 # nixpkgs.overlays = [
 # (self: super: {
 #   dwm = super.dwm.overrideAttrs (oldAttrs: rec {
 #     
 #      #src = builtins.fetchGit "https://github.com/LukeSmithxyz/dwm";
 #     #patches = [
 #       #./path/to/my-dwm-patch.patch
 #       #];
 #     configFile = super.writeText "config.h" (builtins.readFile /home/bl/df/1-nixos/sub/software/dwm/config.h);
 #     #configFile = super.writeText "config.h" (builtins.readFile /home/bl/df/1-nixos/sub/software/dwm/config.h);
 #     #postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
 #     });
 #   })
 # ];
  #specialisation = {
    #external-display.configuration = {
      #system.nixos.tags = ["external-display"];
      #hardware.nvidia.prime.offload.enable=lib.mkForce false;
      #hardware.nvidia.powerManagement.enable = lib.mkForce false;
    #};
  #};
  #services.xserver.screenSection = ''
    #Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    #Option         "AllowIndirectGLXProtocol" "off"
    #Option         "TripleBuffer" "on"
    #'';
}
