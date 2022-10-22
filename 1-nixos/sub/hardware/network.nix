{pkgs,...}:{
  networking = {
    hostName = "nyx";
    #    interfaces={
    #    enp0s3.ip4=[{
    #      address = "192.168.1.2";
    #      prefixLength = 28;
    #    }];
    #    };
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = false;
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = true;
    };
  };
  #networking.useDHCP = true;
  #networking.interfaces.enp0s3.useDHCP = true;
    environment.systemPackages = with pkgs; [
    nm-tray
  ];
}
