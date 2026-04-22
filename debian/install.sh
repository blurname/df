#!/usr/bin/env bash
# Mac 侧一键引导：装 Lima → 起 Debian 13 VM → VM 内跑 setup.sh
# 用法（Mac terminal）：
#   默认 VM 名 deb13：
#     curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash
#   自定义 VM 名：
#     curl -fsSL https://.../install.sh | bash -s -- mydev
#   或通过环境变量：
#     VM_NAME=mydev curl -fsSL https://.../install.sh | bash
set -euo pipefail

REPO_BASE="https://raw.githubusercontent.com/blurname/df/master/debian"
VM_NAME="${VM_NAME:-${1:-deb13}}"

log() { echo -e "\033[1;36m==>\033[0m $*"; }

log "装 Lima（已装会跳过）"
command -v limactl >/dev/null || brew install lima

# 同名 VM 已存在就直接退出，避免用户误以为装了新的
if limactl list -q 2>/dev/null | grep -qx "$VM_NAME"; then
  cat >&2 <<EOF
VM "$VM_NAME" 已存在，跳过安装。

- 进去：          limactl shell $VM_NAME
- 删掉重装：      limactl stop $VM_NAME && limactl delete $VM_NAME
                  然后重跑本命令
- 另起一个测试：  本命令末尾加参数，例如
                  curl ... install.sh | bash -s -- ${VM_NAME}-test
EOF
  exit 0
fi

# Lima 挂载不存在的 host 目录会起不来，先确保存在
mkdir -p "$HOME/git"

log "下载 VM 配置"
YAML=$(mktemp -t lima-deb13).yaml
curl -fsSL "${REPO_BASE}/lima/deb13.yaml" -o "$YAML"

log "启动 VM ($VM_NAME)"
limactl start --name="$VM_NAME" --tty=false "$YAML"

log "VM 内跑 setup.sh（装 apt 包 + node + pnpm + claude code + lazygit）"
limactl shell "$VM_NAME" bash -c "curl -fsSL ${REPO_BASE}/setup.sh | bash"

cat <<EOF

========================================
完成。进 VM：
  limactl shell $VM_NAME

~/git 可写，其余 home 只读。端口自动转发到 Mac localhost。
========================================
EOF
