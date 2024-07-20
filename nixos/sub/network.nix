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
        X11Forwarding = true;
      };
    };
  };
  users.users.bl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2gwRBW5CAqQkLiRempjEr+WtO+KlTRvehEk8rNRfDB Nyx_vm"
  ];
}
