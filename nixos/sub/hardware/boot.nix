{ config, pkgs, ... }:
{
# Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
# hid_apple below fix the F1-12 Key's action of `Keychron`
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    '';
  boot.kernelModules = [ "hid-apple"  ];
  #services.blueman.enable = true;
  #hardware.bluetooth.enable = true;
  #boot.supportedFilesystems = [ "ntfs" ];
}
