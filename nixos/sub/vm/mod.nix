# 虚拟机模块 - 无 GUI 软件
{ config, pkgs, ... }:
{
  imports = [
    # 导入通用模块
    ../common/mod.nix
    # VM 专用模块
    ./network.nix
    ./vscode-remote.nix  # VSCode Remote SSH workaround
  ];
  
  # 虚拟机不需要图形界面
  services.xserver.enable = false;
}

