# nix

## 装机（从官方 NixOS live ISO）

```bash
nix-shell -p git curl --run \
  "curl -fsSL https://raw.githubusercontent.com/blurname/df/master/nixos/install.sh -o /tmp/install.sh && sudo bash /tmp/install.sh vm"
```

参数：`vm`（Hyper-V / UTM / QEMU）或 `host`（物理机）。

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
