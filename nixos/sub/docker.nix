{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    virt-manager
    docker-compose_1
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
}
