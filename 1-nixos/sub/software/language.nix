{ config,pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    rustup
      python39
      gcc gnumake
      go
      nodejs yarn nodePackages.pnpm
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
