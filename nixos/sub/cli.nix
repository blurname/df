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
    fzf
    glab

    zellij 
    tmux

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
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

     #services.v2raya.enable = true;
    services.xserver = {
      enable = true;
    };

}
