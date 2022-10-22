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
  i18n.inputMethod = {
    enabled = "fcitx5";

    fcitx.engines = with pkgs.fcitx-engines; [ rime ];
    fcitx5.enableRimeData= true;
    fcitx5.addons = with pkgs;
    [
      fcitx5-rime
      fcitx5-chinese-addons
    ];
  };
  #   programs.npm = {
  #   enable = true;
  #   npmrc =''
  #     prefix = /home/bl/.npm-global
  #     registry=https://registry.npmmirror.com/
  #     '';
  # };
}  
  