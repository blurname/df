{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    rustup
    python39
    nodejs
    gcc
    go
    yarn
    nixpkgs-fmt
  ];
  #   programs.npm = {
  #   enable = true;
  #   npmrc =''
  #     prefix = /home/bl/.npm-global
  #     registry=https://registry.npmmirror.com/
  #     '';
  # };
}