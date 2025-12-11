{ config,pkgs,pkgs-2405,pkgs-2411,...}:
{
  environment.systemPackages = with pkgs; [
    # elvish
    git
    starship
    eza
    bat
    # ghostty
    alacritty
    ghostty
    bash
    # bottom
    btop
    # htop
    carapace
    fd
    fzf
    glab

    zellij 
    # tmux

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
    
     ] ++ [
    # old-version
    # pkgs-2411.lazygit
    # pkgs-2405.zellij
  ];
  programs.nix-ld = {
    enable = true;
    # package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  services.v2raya.enable = true;
}
