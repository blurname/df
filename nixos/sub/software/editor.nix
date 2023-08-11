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
    emacs
    #neovim-nightly
    vscode
    # lsp
    nil 
    # haskell-language-server 
    # lsp below has been controlled by coc-xxx
    # rust-analyzer
    # sumneko-lua-language-server
    # vimPlugins.coc-sumneko-lua
    lua-language-server
  ];
  #	 programs.neovim = {
	#	 enable = true;
	#	 defaultEditor = true;
	#	 configure = {
	#		 customRC = builtins.readFile /home/bl/.config/nvim/init.vim;
	#		 packages.myVimPackage = with pkgs.vimPlugins;{
	#		 	start = [ packer-nvim ];
	#		 };
	# 	};
	# };
}
