{
	description="blurname's flake";
	inputs={
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		home-manager = {
			url="github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		#neovim-nightly ={
		#url ="github:nix-community/neovim-nightly-overlay";
		#inputs.nixpkgs.follows = "nixpkgs";
		#};
		hyprland = {
      		url = "github:hyprwm/Hyprland";
      		# build with your own instance of nixpkgs
      		inputs.nixpkgs.follows = "nixpkgs";
    };
	};
	outputs = inputs@{self,nixpkgs,hyprland,...}:{
		nixosConfigurations={
			nyx = nixpkgs.lib.nixosSystem{
				system ="x86_64-linux";
      			specialArgs = inputs;
				modules=[
					./configuration.nix
					hyprland.nixosModules.default
        			{ programs.hyprland.enable = true; }
				];
			};
		};
	};
}
