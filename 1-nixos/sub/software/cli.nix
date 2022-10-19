{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    git
    starship
    exa
    bat
    alacritty
    bottom
    htop
    carapace
    fd
    fzf
    zellij
    curl
    unzip
    ripgrep
    wget
    feh
    neofetch
    lf
    lazygit
  ];
}