#!/usr/bin/env bash
# Mac-side bootstrap: install Lima -> start Debian 13 VM -> run setup.sh inside
# Usage (Mac terminal):
#   Default VM name "deb13":
#     curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash
#   Custom VM name:
#     curl -fsSL https://.../install.sh | bash -s -- mydev
#   Or via env var:
#     VM_NAME=mydev curl -fsSL https://.../install.sh | bash
set -euo pipefail

REPO_BASE="https://raw.githubusercontent.com/blurname/df/master/debian"
VM_NAME="${VM_NAME:-${1:-deb13}}"

log() { echo -e "\033[1;36m==>\033[0m $*"; }

log "Installing Lima (skipped if already present)"
command -v limactl >/dev/null || brew install lima

# Bail out if a VM with the same name already exists, so users don't
# mistakenly think a fresh install happened.
if limactl list -q 2>/dev/null | grep -qx "$VM_NAME"; then
  cat >&2 <<EOF
VM "$VM_NAME" already exists — skipping install.

- Enter it:           limactl shell $VM_NAME
- Wipe and reinstall: limactl stop $VM_NAME && limactl delete $VM_NAME
                      then re-run this command
- Spin up another:    pass a different name as argument, e.g.
                      curl ... install.sh | bash -s -- ${VM_NAME}-test
EOF
  exit 0
fi

# Lima fails to start if a mount source on the host doesn't exist.
mkdir -p "$HOME/git"

log "Downloading VM config"
YAML=$(mktemp -t lima-deb13).yaml
curl -fsSL "${REPO_BASE}/lima/deb13.yaml" -o "$YAML"

log "Starting VM ($VM_NAME)"
limactl start --name="$VM_NAME" --tty=false "$YAML"

log "Running setup.sh inside the VM (apt packages + node + pnpm + claude code + lazygit)"
limactl shell "$VM_NAME" bash -c "curl -fsSL ${REPO_BASE}/setup.sh | bash"

cat <<EOF

========================================
Done. Enter the VM with:
  limactl shell $VM_NAME

~/git is writable; the rest of your Mac home is read-only.
Ports bound in the VM auto-forward to Mac localhost.
========================================
EOF
