
#use str
#use epm

set paths = [
      ~/.npm-global/bin
      ~/.cargo/bin
      ~/.local/bin
      $@paths
    ]

set E:RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup"
set E:RUSTUP_DIST_SERVER = "https://mirrors.tuna.tsinghua.edu.cn/rustup"
set E:CARGO_HTTP_MULTIPLEXING = "false"
set E:EDITOR = "nvim"
#set E:HTTP_PROXY = "http://127.0.0.1:8889"
#set E:HTTPS_PROXY = "https://127.0.0.1:8889"


fn l {||e:exa -la}
fn c {||clear }
fn s {||e:neofetch}
fn cb {||cd ../}
fn cbb {||cd ../../ }
fn cbbb {||cd ../../../ }
fn cbbbb {||cd ../../../../ }

fn lg {||e:lazygit}

# dictionary jump
fn cdn {||cd ~/Nyx}
fn cdp {||cd ../}

#dotfile
fn nas {||bash ~/Nyx/apply-system.sh }
fn nes {||nvim ~/Nyx/system/configuration.nix }

#git
fn GAA {||git add .}
fn GCM {|a|git commit -m $a}
fn GCL {|a|git clone 'https://github.com/'$a}
fn GPS {|| git push}
fn GPSF {|| git push --force}
fn GPL {|| git pull}
fn GRHH {|| git reset --hard HEAD~}
fn GRHR {|remote| git reset --hard $remote }
fn GRSH {|| git reset --soft HEAD~}

fn GCOB {|a| git checkout -b $a}
fn GCOT {|a| git checkout --track $a}
fn GBD {|a| git branch --delete --force $a}
fn GBDR {|remote| git branch --}

fn GRI {|a| git rebase -i $a}
fn GRA {|| git rebase --abort}
fn GRC {|| git rebase --continue}
fn GCPA {|| git cherry-pick --abort}
fn GCPC {|| git cherry-pick --continue}

#docker
fn DCLA {||docker ps -a}
fn DCLS {||docker ps}

fn mksh {|a|
	touch $a
	chmod 764 $a
}

fn e {|a|nvim $a}
fn erc {||nvim ~/.elvish/rc.elv}
fn exm {||nvim ~/.xmonad/xmonad.hs}
fn nvimrc {||nvim ~/.config/nvim/entry.vim}

eval (starship init elvish) 2> /dev/null
#epm:install github.com/zzamboni/elvish-completions
#epm:install github.com/zzamboni/elvish-modules
#use github.com/zzamboni/elvish-completions/cd
#use github.com/zzamboni/elvish-completions/git
