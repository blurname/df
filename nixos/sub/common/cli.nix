# CLI 工具 - NixOS 和 Darwin 共用
{ config, pkgs, pkgs-2405, pkgs-2411, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    starship
    eza
    bat
    ghostty
    bash
    bottom
    btop
    carapace
    fd
    fzf

    zellij
    tmux

    curl
    ripgrep
    wget
    neofetch
    lazygit

    p7zip
    zip
    unzip
  ] ++ [
    # old-version
    # pkgs-2411.lazygit
    # pkgs-2405.zellij
  ];
}

