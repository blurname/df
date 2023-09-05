{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    git
    starship
    exa
    bat
    alacritty  kitty
    bash
    bottom
    #htop
    carapace
    fd
    fzf
    zellij
    #curl
    #unzip
    ripgrep
    wget
    #feh
    neofetch
    lazygit
    #dutree
# file manager
    yazi # joshuto lf llama #felix-fm chafa
    #asciiquarium
    nerdfonts
    bsdgames
    
     ];

     services.v2raya.enable = true;
}
