{pkgs,...}:{
  networking = {
    hostName = "nyx";
    interfaces.eth1 = {
    ipv4.addresses = [{
      address = "10.42.1.3";
      prefixLength = 24;
    }];
  };
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
      settings = {
        PasswordAuthentication = true;
      };
    };
  };
}
