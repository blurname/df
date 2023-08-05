{ config,pkgs,...}:
{
  fonts.packages = with pkgs;[
      source-han-serif
      #inconsolata-nerdfont
      lxgw-wenkai
      iosevka
      jetbrains-mono

  ];
  environment.systemPackages = with pkgs; [
    nerdfonts
  ];
}
