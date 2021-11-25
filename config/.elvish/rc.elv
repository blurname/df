
#use str
#use epm


E:RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup"
E:RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
E:CARGO_HTTP_MULTIPLEXING = "false"
E:EDITOR = "nvim"

fn l []{e:exa -la}
fn c []{clear }
fn s []{e:neofetch}

fn lg [@a]{e:lazygit}
fn btm []{e:btm}
fn n []{cd ~/Nyx}
fn nas []{bash ~/Nyx/apply-system.sh }
fn nes []{nvim ~/Nyx/system/configuration.nix }

fn mksh [@a]{
	e:touch $@a 
	e:chmod 777 $@a 
	}

fn e [@a]{e:nvim $@a}

eval (starship init elvish)
#epm:install github.com/zzamboni/elvish-completions
#epm:install github.com/zzamboni/elvish-modules
#use github.com/zzamboni/elvish-completions/cd
#use github.com/zzamboni/elvish-completions/git
