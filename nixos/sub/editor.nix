{ config,pkgs,pkgs-unstable,...}:
{
   #nixpkgs.overlays = [
   #(import (builtins.fetchTarball {
     #url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
   #}))
 #];
  environment.systemPackages =  [
    pkgs.vim

    pkgs-unstable.neovim 
    # neovim
    # openvscode-server
    #emacs
    #neovim-nightly
    #vscode
    # lsp
    # nil 
    # haskell-language-server 
    # lsp below has been controlled by coc-xxx
    # rust-analyzer
    # sumneko-lua-language-server
    # vimPlugins.coc-sumneko-lua
    # lua-language-server
  ];
   # thanks to this video https://www.youtube.com/watch?v=CbDVUjbqIhc
   # need run 
   systemd.user = {
    paths.vscode-remote-workaround = {
      wantedBy = ["default.target"];
      pathConfig.PathChanged = "%h/.vscode-server/bin";
    };
    services.vscode-remote-workaround.script = ''
      for i in ~/.vscode-server/bin/*; do
        echo "Fixing vscode-server in $i..."
        ln -sf ${pkgs.nodejs_18}/bin/node $i/node
      done
    '';
    # units.vscode-remote-workaround.enable = true;
  };
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
