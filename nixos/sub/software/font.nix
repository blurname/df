{ config,pkgs,...}:
{
  fonts.packages = with pkgs;[
      source-han-serif
      #inconsolata-nerdfont
      lxgw-wenkai
      iosevka
      jetbrains-mono
  (nerdfonts.override { fonts = [ "Iosevka" ]; })

  ];
  # environment.systemPackages = with pkgs; [
  #   nerdfonts
  # ];
}
