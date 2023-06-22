{ config,pkgs,...}:
{
  fonts.fonts = with pkgs;[
      source-han-serif
      #inconsolata-nerdfont
      lxgw-wenkai
      iosevka
  ];
  environment.systemPackages = with pkgs; [
    nerdfonts
  ];
}
