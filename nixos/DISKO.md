# disko 迁移计划

## 背景

当前磁盘布局靠 `install-prepare.sh` 里 ~30 行 shell（parted + mkfs），脚本脆弱、不进 git、多平台需要分支。目标：用 [disko](https://github.com/nix-community/disko) 把分区布局声明式化，和 flake 统一。

## 三阶段渐进，不做大迁移日

### 阶段 1：install-time-only disko（立即做）

只在**新安装**时用 disko CLI 分区，**不**作为 NixOS 运行时模块导入。

**变更**：
- `flake.nix` 加 disko input
- 新增 `nixos/disko.nix` —— 独立模块，takes `device` arg
- 新增 `nixos/install.sh` —— 单文件装机脚本
- `configuration-vm.nix` / `configuration-host.nix` 条件导入 `hardware-configuration.nix` 和 `local.nix`
- 删 `install-prepare.sh` / `install-flake.sh` / `script/0-nixos-install.sh`

**装机流程**：
```bash
# ISO 里跑
nix run github:nix-community/disko -- --mode destroy,format,mount \
  ./nixos/disko.nix --argstr device "/dev/sda"
nixos-generate-config --root /mnt         # 生成完整 hw-config（含 UUID fileSystems）
nixos-install --flake .#nyx-vm --impure
```

**对现有运行系统影响**：零。disko.nix 没人 import，flake.lock 多一条记录仅此而已。

### 阶段 2：新机器用 runtime disko（按需触发）

某台新机器或重装时，把 disko 升级为运行时模块，`fileSystems` 由 disko 生成，hw-config 用 `--no-filesystems` 只留硬件部分。

**触发条件**：重装 / 新开一台 VM。

**那台机器的变更**：
- `sub/vm/mod.nix` 或 `sub/host/mod.nix` 加 `imports = [ inputs.disko.nixosModules.disko ../../disko.nix ]`
- 装机脚本改 `nixos-generate-config --no-filesystems --root /mnt`
- 该机器的 `local.nix` 必须正确设置 `disko.devices.disk.main.device`

**收益**：分区布局作为 flake 一部分，真正的单源事实。

**代价**：该机器 `nixos-rebuild switch` 如果 disko.nix 写错，下次重启可能 boot 不起（靠 NixOS generation 回滚救）。

### 阶段 3：全量迁移（不设期限）

老机器自然淘汰/重装时带走 hw-config 路径。不刻意迁移已运行的机器 —— 代价大（partlabel/UUID 不匹配）、收益小（系统已在跑）。

## 已知风险与选择原因

| 问题 | 反映为什么选渐进 |
|---|---|
| 运行中系统 fileSystems 用 mkfs UUID，disko 用 partlabel，二者不等 | 不做原地迁移，等重装 |
| runtime disko 下错误 rebuild 可能 unbootable | 阶段 1 完全不碰运行时，零风险 |
| 每台机器需 `local.nix` 指定正确 device | 阶段 1 的 `local.nix` 仅可选（覆盖 IP 等），阶段 2 起才强制 |
| disko 对 `fileSystems` 默认 options 可能与 hw-config 不同 | 暂时不合并，等真实遇到再处理 |

## 多平台兼容（阶段 1 即可支持）

`install.sh` 自动探测设备，按优先级：
```
/dev/nvme0n1 → /dev/vda → /dev/sda
```

覆盖场景：物理机（NVMe）、Hyper-V（SCSI / sda）、macOS UTM/QEMU（virtio / vda）、Parallels（sda）。

## 回滚

阶段 1 全部变更都可单纯 `git revert`，因为运行时不依赖 disko。阶段 2 以后的机器回滚需要重装或手写 hw-config。

## 相关文件

- `nixos/disko.nix` —— 分区布局（阶段 1 起存在）
- `nixos/install.sh` —— 装机脚本（阶段 1 起存在）
- `nixos/local.nix.example` —— 本地覆盖模板
- `nixos/README.md` —— 装机命令入口
