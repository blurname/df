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
    #neofetch
    lazygit
    #dutree
# file manager
    joshuto lf# llama #felix-fm chafa
    #asciiquarium
    nerdfonts
    bsdgames
    # configuration.nix
    nur.repos.xyenon.yazi
     ];

     services.v2raya.enable = true;
}
