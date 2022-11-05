{ config,pkgs,...}:
{
   #nixpkgs.overlays = [
   #(import (builtins.fetchTarball {
     #url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
   #}))
 #];
  environment.systemPackages = with pkgs; [
    vim
    neovim
    #neovim-nightly
    vscode
    # lsp
    nil rust-analyzer haskell-language-server sumneko-lua-language-server
  ];
  	# programs.neovim = {
		# enable = true;
		# defaultEditor = true;
		# configure = {
			# customRC = builtins.readFile /home/bl/.config/nvim/init.vim;
			# packages.myVimPackage = with pkgs.vimPlugins;{
			# 	start = [ packer-nvim ];
			# };
	# 	};
	# };
}
