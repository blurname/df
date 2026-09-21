# script/pkg — one software list, two package managers

`packages.json` is the list of software this machine should have. The same list
installs through **apt** on Debian and **homebrew** on macOS; everything else in
here is the plumbing that maps one entry to whichever package manager is in front
of it.

Root `package.json` spells out one script per package manager, next to the nix
ones (`flake-apply-*`):

```bash
bun run pkg-status            # list vs machine: what is missing, what is untracked
bun run pkg-list              # every entry with its package name on this backend
bun run pkg-install-apt       # install what is missing, through apt
bun run pkg-install-brew      # install what is missing, through homebrew
```

`bun run pkg <command>` is the same tool with the backend auto-detected (brew if
present, else apt) and takes the flags:

```bash
bun run pkg install -n                 # print the commands instead of running them
bun run pkg install --group app        # a group outside the default install set
bun run pkg status --group cli,dev     # only these groups
bun run pkg status --backend apt       # force a backend
```

`status` and `list` always show the whole list. `install` only covers the groups
that `install.<backend>` declares — on macOS that is `cli,dev`, so brew never
pulls in a desktop app or a font on its own. Anything else is installed by asking
for it: `bun run pkg install --group app`.

## The list

`install` says which groups each package manager installs by default. `groups`
holds the software: one group per line of business, then one entry per piece of
software. The key is the name *you* use for it; the value says how each package
manager spells it:

```jsonc
{
  "install": {
    "apt":  ["cli", "dev", "gui", "font"],
    "brew": ["cli", "dev"]
  },
  "groups": {
    "cli": {
      "ripgrep": "ripgrep",                          // same name everywhere
      "fd":      { "apt": "fd-find", "brew": "fd" }, // different names
      "yazi":    { "brew": "yazi" },                 // brew only
      "bubblewrap": { "apt": "bubblewrap" },         // apt only
      "bun":     { "note": "npm i -g bun on both" }  // neither — documented only
    },
    "app": {
      "aerospace": { "brew": { "cask": "aerospace", "tap": "nikitabobko/tap" } }
    }
  }
}
```

| group | what lives there |
| --- | --- |
| `cli` | shell, terminal and system tools |
| `dev` | languages, toolchains, databases, dev services |
| `gui` | linux desktop apps (fcitx5, firefox-esr, flameshot, virt-manager) |
| `app` | macOS apps installed as casks (aerospace, godot, android-studio) |
| `font` | noto-cjk, iosevka |

A group left out of `install.<backend>` is still tracked: `status` lists what it
is missing under *missing outside the install set*, with the `--group` to run.
On a headless Debian VM, narrow the default the same way: `install --group cli,dev`.

- a **missing backend key** means "not installed that way here" — `install` skips it
  and `list` shows `—`. Add a `note` saying how it *is* installed.
- **`cask`** marks a macOS app instead of a formula; **`tap`** is only needed for
  packages outside homebrew/core.

Two rules keep the list honest:

1. The **apt** side stays in sync with what `debian/setup.sh` installs from apt.
   Things setup.sh fetches from upstream (node, bun, starship, zellij, lazygit,
   gh, zig, chrome, iosevka) are left `brew`-only with a `note`, so `install`
   never installs a second, older copy from the Debian archive.
2. The **brew** side is the macOS truth: after `brew install` / `brew uninstall`,
   `status` shows the drift as `untracked` / `missing` — then either edit the
   list or run `install`.

`untracked` is what the machine reports as explicitly installed
(`apt-mark showmanual`, `brew leaves --installed-on-request`) but the list does
not declare. On Debian that includes the base system, so it is truncated unless
you pass `--all`.

## Layout

| file | what it does |
| --- | --- |
| `packages.json` | the list |
| `packages.ts` | reads the list, resolves an entry to a package for one backend |
| `backend.ts` | the backend interface, detection, shared types |
| `apt.ts` | dpkg-query / apt-mark / apt-get |
| `brew.ts` | brew list / brew leaves / brew install |
| `cli.ts` | commands, output, dry-run |

A backend only has to answer three things: what is installed (`inventory`), how to
refresh the index (`refreshCommands`), and how to install a set of packages
(`installCommands`). Commands are returned, not run, so `--dry-run` prints exactly
what a real run would execute. Adding a third package manager means one file.

## Scope

This does not replace `debian/setup.sh` — that still bootstraps a fresh VM
(mirrors, upstream tarballs, repos, fonts) before bun exists. This is the day-two
tool: keep the list current, see the drift, fill in what a machine is missing.
It only ever adds packages; it never removes or upgrades anything.
