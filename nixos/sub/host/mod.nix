# 实体机模块 - 包含 GUI 软件
{ config, pkgs, ... }:
{
  imports = [
    # 导入通用模块
    ../common/mod.nix
    # GUI 相关模块
    ./gui/minigui.nix
    # ./gui/x11.nix
    ./gui/wayland.nix
    ./gui/font.nix
  ];
}

