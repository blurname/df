{
  description="blurname's flake";
    nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      # replace official cache with a mirror located in China
      "https://mirrors.bfsu.edu.cn/nix-channels/store"
    ];

    # nix community's cache server
    #extra-substituters = [
      #"https://nix-community.cachix.org"
    #];
    #extra-trusted-public-keys = [
      #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    #];
  };
  inputs={

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    #home-manager = {
      #url="github:nix-community/home-manager";
      #inputs.nixpkgs.follows = "nixpkgs";
    #};

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
  outputs = inputs@{self,nixpkgs,...}:{
    nixosConfigurations={
      nyx = nixpkgs.lib.nixosSystem{
        system ="x86_64-linux";
        specialArgs = inputs;
        modules=[
          ./nixos/configuration.nix
        ];
      };
    };
  };
}
