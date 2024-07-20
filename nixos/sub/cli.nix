{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    elvish
    git
    starship
    eza
    bat
    # alacritty  kitty
    bash
    bottom
    htop
    carapace
    fd
    #fzf
    zellij
    curl
    #unzip
    ripgrep
    wget
    #feh
    neofetch
    lazygit
    #dutree
# file manager
    # yazi ueberzugpp # joshuto lf llama #felix-fm chafa 
    #asciiquarium
    # nerdfonts
    # bsdgames
    p7zip zip unzip
    #tmux
    
     ];

     #services.v2raya.enable = true;
    services.xserver = {
      enable = true;
    };

}
