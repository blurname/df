{config,pkgs,...}:
{
 imports = [
  ./audio.nix
  ./network.nix
  ./boot.nix
 ];
}
