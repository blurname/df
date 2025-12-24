# 通用网络配置
{pkgs,...}:{
  networking = {
    hostName = "nyx";
    networkmanager = {
      enable = true;
    };
    firewall = {
      enable = false;
    };
  };
}

