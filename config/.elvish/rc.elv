#( •̀ ω •́ )✧
set paths = [
      ~/.npm-global/bin
      ~/.cargo/bin
      ~/.local/bin
      ~/.deno/bin
      /bin
      /usr/bin
      $@paths
    ]

set E:TERM = 'xterm-256color'
set E:RUSTUP_DIST_SERVER = "https://rsproxy.cn"
set E:RUSTUP_UPDATE_ROOT = "https://rsproxy.cn/rustup"
set E:CARGO_HTTP_MULTIPLEXING = "false"
set E:LESSCHARSET = "utf-8"
set E:EDITOR = "nvim"
set E:BEMENU_BACKEND = "wayland"
# set E:HTTP_PROXY = "http://127.0.0.1:10809"
# set E:HTTPS_PROXY = "https://127.0.0.1:10809"


fn l {|| e:exa -la}
fn c {|| clear }
fn s {|| e:neofetch}
fn lg {|| lazygit}

fn bd {|| bat ~/.elvish/rc.elv}

# dictionary jump
fn cb {|| cd ../}
fn cbb {|| cd ../../ }
fn cbbb {|| cd ../../../ }
fn cbbbb {|| cd ../../../../ }
fn cdn {|| cd ~/Nyx}
fn cdp {|| cd ../}

# dotfile
fn e {|@a| nvim $@a}
fn nas {|| bash ~/Nyx/001-NixOS/apply-system.sh }
fn nes {|| nvim ~/Nyx/001-NixOS/configuration.nix }
fn erc {|| nvim ~/.elvish/rc.elv}
fn ep {|| nvim ./package.json}
fn exm {|| nvim ~/.xmonad/xmonad.hs}
fn envimrc {|| nvim ~/.config/nvim/entry.vim}

# git
# suffix:
# c -> continue
# d -> directly
# s -> specific
# r -> remote
# a -> all/abort
# f -> force
# i -> interactive/index
# n -> new/name

fn gitconfiginitglobal {||
  git config --global user.name "blurname"
  git config --global user.email "naughtybao@outlook.com"
}

fn gitconfiginit {||
  git config user.name "blurname"
  git config user.email "naughtybao@outlook.com"
  git config credential.helper store
}

fn gwip {|m| 
  git add .
  git commit -am "WIP: "$m -n
} 

fn gcm {|commitMessage|
  git add .
  git commit -am $commitMessage
}
fn gcamend {||
  git commit --amend
}

fn gcl {|repoName| git clone 'https://github.com/'$repoName}

fn gpsd {|| git push}
fn gpsf {|| git push --force}
fn gpsn {||
  var name = (git branch --show-current)
  put $name
  git push --set-upstream origin $name --force
}

fn gpla {|| git pull --rebase}
fn gpls {|remoteBranch| git pull origin/$remoteBranch $remoteBranch}

fn grhh {|| git reset --hard HEAD~}
fn grhn {|hashId| git reset --hard $hashId}
fn grhr {||
  var name = (git branch --show-current)
  put $name
  git fetch
  git reset --hard origin/$name 
}
fn grsh {|| git reset --soft HEAD~}

fn gssd {|| git stash save}
fn gssn {|stashName| git stash save $stashName}
fn gsl {|| git stash list}
fn gsad {|| git stash apply}
fn gsai {|index| git stash apply $index}

fn gl {|@b| git log --pretty=format:"%Cred%h %C(yellow)%ad %Cgreen[%an] %Cblue%s %Cred%d" --date=short $@b}
fn gd {|| git diff}
fn gs {|| git status}

# fetch
fn gf {|| git fetch}
fn gfs {|branch| git fetch origin $branch}
fn gfp {|| git fetch -- prune}

# checkout
fn gco {|a| git checkout $a}
fn gcom {|| git checkout master}
fn gcob {|a| git checkout -b $a}
fn gcobr {|branch| git checkout -b $branch origin/$branch}
fn gbd {|a| git branch --delete --force $a}
fn gcobf {|a|
  gbd $a
  gcob $a
}
fn gcor {|b| 
  gco $b
  grhr
}
fn gcot {|a| git checkout --track $a}

# branch
fn gbl {|| git branch --sort=-committerdate }
fn gbla {|| git branch -a}

# rebase & cherry-pick
fn gri {|a| git rebase -i $a}
fn gra {|| git rebase --abort}
fn grc {||
  git add .
  git rebase --continue
}
fn gcpi {|a| git cherry-pick $a}
fn gcpa {|| git cherry-pick --abort}
fn gcpc {|| git cherry-pick --continue}

# misc
fn GDA {|| git restore .}

# glab
fn GPR {|target| glab mr new -b $target -f -y}
fn GPRD {|target desc| glab mr new -b $target -d $desc -y}

# docker
fn dcla {||docker ps -a}
fn dcls {||docker ps}

# global npm package command 
fn nkp {|a| kill-port $a}
fn nts {|@file| node -r '@swc-node/register' $@file}

# new a script
fn mksh {|a|
	touch $a.sh
	chmod 764 $a.sh
  nvim $a.sh
}
fn mkelv {|a|
	touch $a.elv
	chmod 764 $a
  nvim $a.elv
}

# du
fn dush {|@path|
  du -sh  $@path
}

# cp path
fn rcpdry {|old new|
  rsync --verbose --archive --dry-run $old $new
}
fn rcp {|old new|
  rsync --verbose --archive $old $new
}

# mv path
fn rmovedry {|old new|
  rsync --verbose --archive --delete-after --dry-run $old $new
}
fn rmove {|old new|
  rsync --verbose --archive --delete-after $old $new
}

# deno
fn drw {|path| deno run --watch $path }
fn draa {|path| deno run --allow-all $path}

# self ts script
fn bl {|@command| 
  tsx ~/prjs/bl-ts/src/node/scripts/main.ts $@command
}

# mb
fn mockupdate {|| bash ~/iupdate.sh}
fn mbNI {|| npm install }
fn mbBP {|| npm run version-bump ; npm run tag-push}
fn mbR {|@target| tsx /home/bl/git/bl-scripts/0009-mb-git-package-replace.ts $@target}
fn mbD {|| tsx /home/bl/git/bl-scripts/0010-mb-git-detect-ci-status.mts}
fn mbDR {|@target| mbD; mbR $@target}
fn mbBPDR {|@target| mbBP; mbD; mbR $@target}
fn mbCommit {|| tsx /home/bl/git/bl-scripts/0008-mb-git-package-commit.ts}
fn mbDropVersion {|@commitHash| tsx /home/bl/git/bl-scripts/0008-mb-git-drop-version.mts $@commitHash}
fn mbEnvStart {|| elvish /home/bl/git/bl-scripts/0011-mb-start-env.elv}

# bindings
set edit:insert:binding[Alt-w] = $edit:insert:binding[Alt-f]
set edit:insert:binding[Alt-h] = $edit:insert:binding[Home]
set edit:insert:binding[Alt-l] = $edit:insert:binding[End]

eval (starship init elvish) 2> /dev/null
eval (carapace _carapace|slurp)
