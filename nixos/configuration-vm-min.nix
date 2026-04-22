# 虚拟机最小配置 - 用于测试 install.sh 装机流程
# 仅包含：boot + 用户 + ssh + flakes + 国内镜像
# 不 import sub/common/mod.nix（跳过 cli/editor/docker/language/xrdp 等）
{ config, pkgs, ... }:
{
  imports = [ ]
  ++ (if builtins.pathExists /etc/nixos/hardware-configuration.nix
        then [ /etc/nixos/hardware-configuration.nix ] else [])
  ++ (if builtins.pathExists ./local.nix
        then [ ./local.nix ] else []);

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.bl = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "b";
  };

  security.sudo.extraRules = [
    {
      users = [ "bl" ];
      commands = [{
        command = "ALL";
        options = [ "SETENV" "NOPASSWD" ];
      }];
    }
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  environment.systemPackages = [ pkgs.git ];

  system.stateVersion = "25.11";
}
