# nix

## 装机（从官方 NixOS live ISO）

```bash
curl -fsSL https://raw.githubusercontent.com/blurname/df/master/nixos/install.sh -o /tmp/install.sh && sudo bash /tmp/install.sh vm-2604
```

参数：`vm-2604`（Hyper-V / UTM / QEMU）、`host-2604`（物理机）、`server-2604`（btrfs impermanence），或 `vm-min-2604`（最小配置，用于验证装机流程本身，不拉 GUI/docker/editor/language）。yymm 后缀随装机样式演进，详见 `DISKO.md`。

装完 reboot → 登录 `bl`（密码 `b`）→ `cd ~/df && npm run sync-home-config`

## 更新已装系统

```bash
bash nixos/apply-system.sh <vm|host|wsl|darwin>
```

## 多 VM 不撞 IP

```bash
cp nixos/local.nix.example nixos/local.nix
# 编辑 IP 和 hostname
```

不创建则用默认 `10.42.1.3`。

## 其它

- `nixos/DISKO.md` —— disko 迁移计划（为何目前是 install-time-only）
- `nixos/install-darwin.sh` —— macOS 引导（非 NixOS）
