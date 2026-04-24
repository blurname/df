# debian

One-liner setup for a Debian 13 development VM on Mac via Lima.

## One-liner install (paste in Mac terminal)

```bash
curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash
```

This does four things: install Lima → fetch VM config → start Debian 13 VM → run setup.sh inside the VM to install the toolchain. Works on macOS 13+ (Apple Silicon or Intel), takes ~10-15 min (mostly Debian cloud image download + apt installs).

To use a different VM name (or spin up a second test VM):

```bash
curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash -s -- mydev
```

Note: `-s --` passes the arg to the script, not to bash itself.

Later, to enter the VM:

```bash
limactl shell deb13
```

## What gets installed

- **apt**: git, neovim, tmux, fzf, ripgrep, fd, bat, jq, htop, btop, fastfetch, build-essential, python3, ... — 27 packages total
- **binaries**: Node 22.19.0, pnpm, claude code, lazygit
- **Lima config**: Apple Virtualization + virtiofs + writable `~/git`

Scripts are idempotent — safe to re-run.

## Customization

- **Change CPU / memory**: edit `cpus` / `memory` in `debian/lima/deb13.yaml`, then `limactl stop/start`
- **Add writable mount**: append `- location: "~/foo"` with `writable: true` under `mounts:`
- **Change Node version**: edit `NODE_VERSION` at the top of `setup.sh` and re-run

## Port forwarding

Any TCP port bound inside the VM (e.g. by `pnpm dev`, `bun dev`) is auto-forwarded to Mac `localhost`. Just open `http://localhost:<port>` in the Mac browser.

## Bare-metal install (physical machine or fresh VM)

For installing Debian 13 directly onto hardware (not via Lima), use `install-host.sh`. Boot any Linux live ISO (Debian / Ubuntu live works best), then:

```bash
sudo bash install-host.sh <vm-2604|host-2604>
```

Targets:
- `vm-2604` — VM install (no firmware blobs)
- `host-2604` — physical host (pulls `firmware-linux` for WiFi/BT)

What it does: partitions the disk (GPT + ESP + btrfs with `@root`/`@home` subvolumes), debootstraps Debian 13 from Tsinghua, chroots to install kernel + GRUB-EFI + NetworkManager + sshd + user `bl`, and seeds `/home/bl/df`. After reboot, run `bash debian/setup.sh` for the dev toolchain.

Mirrors the architecture of `nixos/install.sh`. Disk is wiped; you'll be prompted to type `YES` before anything destructive happens.

## Docker (manual, on demand)

The script does not install Docker automatically — the official script pulls `docker-model-plugin` and other new plugins whose Debian 13 arm64 packaging can be flaky. Install manually when needed:

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# log out and back in
```
