# ~/.zshrc — ported from ~/.config/elvish/rc.elv on the move from elvish to zsh.
# elvish is still installed (mbStartEnv etc. still work); this is now the login
# shell so agents and shared bash commands run without translation.
#
#( •̀ ω •́ )✧

# ---- PATH ----------------------------------------------------------------
typeset -U path   # keep entries unique
path=(
  ~/.npm-global/bin
  ~/.cargo/bin
  ~/.local/bin
  ~/.deno/bin
  ~/.moon/bin
  ~/.elan/bin
  /opt/homebrew/bin
  $path
)

# ---- environment ---------------------------------------------------------
export TERM='xterm-256color'
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
export CARGO_HTTP_MULTIPLEXING="false"
export LESSCHARSET="utf-8"
export EDITOR="nvim"
export BEMENU_BACKEND="wayland"
export MANPAGER='nvim +Man!'
export MANWIDTH=999
export _JAVA_AWT_WM_NONREPARENTING=1
export XCURSOR_SIZE=24
export WLR_NO_HARDWARE_CURSORS=1

# ---- history -------------------------------------------------------------
# adx owns Up/Down/Ctrl-R, but zsh's own history still backs `fc`, `!!`, and is
# what `adx import zsh` reads.
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
setopt EXTENDED_HISTORY SHARE_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
setopt INTERACTIVE_COMMENTS

# ---- keymap & completion -------------------------------------------------
bindkey -e   # emacs keybindings (must precede adx so its binds land here)
autoload -Uz compinit && compinit -u

# ---- tools ---------------------------------------------------------------
# zsh gets its own starship config (magenta "zsh" badge) so it's distinct from
# the elvish prompt, which keeps reading ~/.config/starship.toml.
export STARSHIP_CONFIG="$HOME/df/config/starship-zsh.toml"
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v carapace >/dev/null && source <(carapace _carapace zsh)

# fzf (env only; adx owns Ctrl-R, so fzf's key-bindings are intentionally not sourced)
export FZF_DEFAULT_COMMAND="fd --hidden --follow --type f --type l --exclude .git"
export FZF_DEFAULT_OPTS="
  --reverse
  --height 85%
  --multi
  --scrollbar '█'
  --history /tmp/fzfhistory
  --prompt 'FZF> '
  --tabstop=2
  --highlight-line
  --color=fg:#000000,bg:#f7f7f7,hl:#7a3e9d
  --color=fg+:#000000,bg+:#e4e4e4,hl+:#7a3e9d
  --color=info:#bc5215,prompt:#2c5aa0,pointer:#7a3e9d
  --color=marker:#448c27,spinner:#2c5aa0,header:#448c27
  --color=border:#cccccc,gutter:#f7f7f7
  --bind 'ctrl-d:half-page-down,ctrl-u:half-page-up,alt-d:preview-half-page-down,tab:down,btab:up'
"
f() { fzf }

# ---- shortcuts -----------------------------------------------------------
# NixOS programs.zsh pre-defines aliases (l, ll, ls) in /etc/zshrc; zsh expands
# aliases even in function DEFINITIONS, so `l() {...}` would parse as
# `ls -alh() {...}` and explode. Drop foreign aliases before defining ours.
unalias -a
alias ls='ls --color=auto'  # keep colored ls (the /etc alias we just removed)

l()  { eza -la "$@" }       # rc.elv used eza; exa is what's installed here
c()  { clear }
s()  { fastfetch }
lg() { lazygit }
lk() { lazydocker }
bd() { bat ~/.zshrc }       # was rc.elv; now this file
cb()  { cd ../ }
cbb() { cd ../../ }
la()  { llama }
cdf() { cd ~/df }

# filePath -> cd to its dir and edit it
cdAndEdit() {
  local base=${1:h}
  print -r -- "$base"
  cd "$base" && nvim "$1"
}

# dotfiles
e()   { nvim "$@" }
nas() { bash ~/df/nixos/apply-system.sh }
nes() { cdAndEdit ~/df/nixos/flake.nix }
r()   { exec zsh }
erc() { cdAndEdit ~/.zshrc }
envimrc() { cdAndEdit ~/.config/nvim/entry.vim }

# edit the project's meta file
ep() {
  if   [[ -f package.json ]]; then nvim ./package.json
  elif [[ -f Cargo.toml   ]]; then nvim ./Cargo.toml
  elif [[ -f init.vim     ]]; then nvim ./init.vim
  elif [[ -f flake.nix    ]]; then nvim ./flake.nix
  elif [[ -f README.md    ]]; then nvim ./README.md
  else print -r -- 'no metaFile here'
  fi
}

# ---- git -----------------------------------------------------------------
# suffix: c continue · d directly · s specific · r remote · a all/abort
#         f force · i interactive/index · n new/name
gitconfiginitglobal() {
  git config --global user.name "blurname"
  git config --global user.email "naughtybao@outlook.com"
  git config --global credential.helper store
}
gitconfiginit() {
  git config user.name "blurname"
  git config user.email "naughtybao@outlook.com"
  git config credential.helper store
}

gwip()    { git add . && git commit --no-verify -am "WIP" }
gcm()     { git add . && git commit --no-verify -am "$1" }
gcamend() { git commit --amend }
gcl()     { git clone "https://github.com/$1" }

gpsd() { git push }
gpsf() { git push --force }
gpsn() {
  local name=$(git branch --show-current)
  print -r -- "$name"
  git push --set-upstream origin "$name" --force
}

gpla() { git pull --rebase }
gpls() { git pull origin/"$1" "$1" }

grhh() { git reset --hard HEAD~ }
grhn() { git reset --hard "$1" }
grhr() {
  local name=$(git branch --show-current)
  print -r -- "$name"
  git fetch
  git reset --hard origin/"$name"
}
grsh() { git reset --soft HEAD~ }

gssd() { git stash save }
gssn() { git stash save "$1" }
gsl()  { git stash list }
gsad() { git stash apply }
gsai() { git stash apply "$1" }

gl() { git log --pretty=format:"%Cred%h %C(yellow)%ad %Cgreen[%an] %Cblue%s %Cred%d" --date=short "$@" }
gd() { git diff }
gs() { git status }

gf()  { git fetch }
gfs() { git fetch origin "$1" }
gfp() { git fetch -- prune }

gco()   { git checkout "$1" }
gcom()  { git checkout master }
gcob()  { git checkout -b "$1" }
gcobr() { git checkout -b "$1" origin/"$1" }
gbd()   { git branch --delete --force "$1" }
gcobf() { gbd "$1"; gcob "$1" }
gcor()  { gco "$1"; grhr }
gcot()  { git checkout --track "$1" }

gbl()  { git branch --sort=-committerdate }
gbla() { git branch -a }

gri()  { git rebase -i "$1" }
gra()  { git rebase --abort }
grc()  { git add . && git rebase --continue }
gcpi() { git cherry-pick "$1" }
gcpa() { git cherry-pick --abort }
gcpc() { git cherry-pick --continue }

GDA() { git restore . }

# glab
GPR()  { glab mr new -b "$1" -f -y --remove-source-branch }
GPRD() { glab mr new -b "$1" -d "$2" -y }

# ---- docker --------------------------------------------------------------
dcla() { docker ps -a }
dcls() { docker ps }

# ---- misc ----------------------------------------------------------------
nkp() { kill-port "$1" }

mksh() { touch "$1.sh"; chmod 764 "$1.sh"; nvim "$1.sh" }

dush() { du -sh "$@" }

rcpdry()   { rsync --verbose --archive --dry-run "$1" "$2" }
rcp()      { rsync --verbose --archive "$1" "$2" }
rmovedry() { rsync --verbose --archive --delete-after --dry-run "$1" "$2" }
rmove()    { rsync --verbose --archive --delete-after "$1" "$2" }

drw()  { deno run --watch "$1" }
draa() { deno run --allow-all "$1" }

tbl() { bun ~/prj/luv-sic/pkg/cli/src/main.ts "$@" }
tm()  { ~/prj/luv-moon/target/native/release/build/main/main.exe "$@" }
nn()  { npm run "$@" }

mbNI()   { npm install }
Nis()    { npm i; npm run start }
mbBP()   { npm run version-bump; npm run tag-push }
mbR()    { bl gitReplacePackage "$@" }
mbD()    { bl detectCIStatus }
mbDR()   { mbD; mbR "$@" }
mbBPDR() { mbBP; mbD; mbR "$@" }
mbCommit()   { bl gitCommit @mb2023 }
mbStartEnv() { elvish ~/prj/script/mb-start.elv }
tl()   { bun ~/prj/laoda/index.ts }
dlog() { node ~/prj/script/dlog.mjs "$@" }

zb() { zellij a b || zellij -s b }

tt()  { timedatectl }
mf()  { bl metaScriptFzf }
blg() { bl generate }

SDHN() { shutdown -h 0 }

prj() { cd ~/prj && exa -la }
# fork a project dir (paths resolved from cwd): prjfork source target  → ./source copied to ./target-3
prjfork() { bun ~/df/script/prjfork.ts "$@" }

# ---- adx (location + history; must be last so its bindings win) ----------
eval "$(adx init zsh)"
# rc.elv habit: Alt-w behaved like Alt-f (forward word / accept a word of ghost)
(( ${+widgets[__adx_forward_word_or_accept]} )) && bindkey '^[w' __adx_forward_word_or_accept
