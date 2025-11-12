{
  description="blurname's flake";
    nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    ];
    trusted-substituters = ["https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"];

    # nix community's cache server
    #extra-substituters = [
      #"https://nix-community.cachix.org"
    #];
    #extra-trusted-public-keys = [
      #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    #];
  };
  inputs={

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    #neovim-nightly ={
      #url ="github:nix-community/neovim-nightly-overlay";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};

    #hyprland = {
      #url = "github:hyprwm/Hyprland";
# build with your own instance of nixpkgs
      #inputs.nixpkgs.follows = "nixpkgs";
    #};
    
    # 添加 NUR 仓库
    #nur.url = "github:nix-community/NUR";
    # 强制 NUR 和该 flake 使用相同版本的 nixpkgs
    #nur.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{self,nixpkgs,nixpkgs-unstable,nixpkgs-2405,nixpkgs-2411,...}:

        let system ="x86_64-linux";
  in {
    nixosConfigurations={
      nyx = nixpkgs.lib.nixosSystem{
        specialArgs = {
          pkgs = import nixpkgs {
            # 这里递归引用了外部的 system 属性
            inherit system;
            config.allowUnfree = true;
          };

          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-2411 = import nixpkgs-2411 {
            inherit system;
            config.allowUnfree = true;
          };
          pkgs-2405 = import nixpkgs-2405 {
            inherit system;
            config.allowUnfree = true;
          };
          };
        modules=[
          # nixos-wsl-vscode.nixosModules.vscodeServerWsl
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
