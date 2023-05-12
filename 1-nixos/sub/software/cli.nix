{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    git
    starship
    exa
    bat
    alacritty 
    #kitty
    bottom
    #htop
    carapace
    fd
    fzf
    zellij
    #curl
    #unzip
    #ripgrep
    wget
    #feh
    #neofetch
    lazygit
    #dutree
# file manager
    #lf# llama #felix-fm chafa
    #asciiquarium
     ];

     services.v2raya.enable = true;
}
