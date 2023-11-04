{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    virt-manager
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
}
