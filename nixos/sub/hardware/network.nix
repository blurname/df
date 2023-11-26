{pkgs,...}:{
  networking = {
    hostName = "nyx";
    interfaces.eth1 = {
    ipv4.addresses = [{
      address = "10.42.1.2";
      prefixLength = 16;
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
