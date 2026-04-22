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

    # NixOS on WSL2
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # 磁盘布局声明式（当前仅 install.sh 通过 CLI 使用；详见 nixos/DISKO.md）
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # impermanence: 服务器配置的持久化清单 + bind-mount 框架
    impermanence.url = "github:nix-community/impermanence";

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
  outputs = inputs@{self,nixpkgs,nixpkgs-unstable,nixpkgs-2405,nixpkgs-2411,darwin,nixos-wsl,disko,impermanence,...}:

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
      # 实体机配置 (2604) - 运行时 disko，用于新装机
      nyx-host-2604 = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-host.nix
          disko.nixosModules.disko
          ./nixos/disko.nix
        ];
      };
      # 虚拟机配置 - 无 GUI 软件
      nyx-vm = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-vm.nix
        ];
      };
      # 虚拟机配置 (2604) - 运行时 disko，用于新装机
      nyx-vm-2604 = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-vm.nix
          disko.nixosModules.disko
          ./nixos/disko.nix
        ];
      };
      # 虚拟机最小配置 (2604) - 用于测试装机流程（最小体积）
      # 不传 linuxSpecialArgs（pre-imported x86_64 pkgs），让 hw-config 里的
      # nixpkgs.hostPlatform 决定架构，这样 aarch64 / x86_64 通用
      nyx-vm-min-2604 = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/configuration-vm-min.nix
          disko.nixosModules.disko
          ./nixos/disko.nix
        ];
      };
      # 服务器配置 (2604) - 运行时 disko + btrfs 快照回滚 impermanence
      nyx-server-2604 = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          ./nixos/configuration-server.nix
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
        ];
      };
      # WSL2 配置
      nyx-wsl = nixpkgs.lib.nixosSystem {
        specialArgs = linuxSpecialArgs;
        modules = [
          nixos-wsl.nixosModules.wsl
          ./nixos/configuration-wsl.nix
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
