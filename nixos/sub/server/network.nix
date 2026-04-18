# 服务器网络 - 默认 DHCP + 严格 ssh（仅密钥）
{ pkgs, lib, ... }:
{
  networking = {
    hostName = lib.mkDefault "nyx-server";
    networkmanager.enable = true;
    firewall.enable = lib.mkDefault true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.bl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2gwRBW5CAqQkLiRempjEr+WtO+KlTRvehEk8rNRfDB Nyx_vm"
  ];
}
