# Darwin 配置 - macOS 专用
{ config, pkgs, ... }:
{
  imports = [
    ./sub/darwin/mod.nix
  ];

  # Nix 守护进程配置
  services.nix-daemon.enable = true;

  # Nix 配置
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-substituters = [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
  };

  # 系统版本（nix-darwin 需要）
  system.stateVersion = 4;
}

