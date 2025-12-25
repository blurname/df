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

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # nix-darwin for macOS
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

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
  outputs = inputs@{self,nixpkgs,nixpkgs-unstable,nixpkgs-2405,nixpkgs-2411,darwin,...}:

        let 
          linuxSystem = "x86_64-linux";
          darwinSystem = "aarch64-darwin";  # Apple Silicon，如果是 Intel Mac 改为 x86_64-darwin
          
          # Linux 共用的 specialArgs
          linuxSpecialArgs = {
            pkgs = import nixpkgs {
              system = linuxSystem;
              config.allowUnfree = true;
            };
            pkgs-unstable = import nixpkgs-unstable {
              system = linuxSystem;
              config.allowUnfree = true;
            };
            pkgs-2411 = import nixpkgs-2411 {
              system = linuxSystem;
              config.allowUnfree = true;
            };
            pkgs-2405 = import nixpkgs-2405 {
              system = linuxSystem;
              config.allowUnfree = true;
            };
          };

          # Darwin 共用的 specialArgs
          darwinSpecialArgs = {
            pkgs = import nixpkgs {
              system = darwinSystem;
              config.allowUnfree = true;
            };
            pkgs-unstable = import nixpkgs-unstable {
              system = darwinSystem;
              config.allowUnfree = true;
            };
            pkgs-2411 = import nixpkgs-2411 {
              system = darwinSystem;
              config.allowUnfree = true;
            };
            pkgs-2405 = import nixpkgs-2405 {
              system = darwinSystem;
              config.allowUnfree = true;
            };
          };
        in {
    nixosConfigurations = {
      # 实体机配置 - 包含 GUI 软件
      nyx = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-host.nix
        ];
      };
      # 虚拟机配置 - 无 GUI 软件
      nyx-vm = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-vm.nix
        ];
      };
    };

    # Darwin 配置 - macOS
    darwinConfigurations = {
      nyx-darwin = darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = darwinSpecialArgs;
        modules = [
          ./nixos/configuration-darwin.nix
        ];
      };
    };
  };
}
