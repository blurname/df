{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    virt-manager
    docker-compose
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
}
