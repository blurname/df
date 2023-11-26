{ config,pkgs,...}:
{
  imports = [
    ./cli.nix
    ./docker.nix
    ./editor.nix
    ./language.nix
    ./boot.nix
    ./network.nix
  ];
  
  nixpkgs.config.allowUnfree = true;
}
