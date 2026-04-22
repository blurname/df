# debian

Mac 上用 Lima 跑 Debian 13 开发 VM 的一键配置。

## 一行安装（复制到 Mac terminal 粘贴执行）

```bash
curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash
```

做了四件事：装 Lima → 下 VM 配置 → 起 Debian 13 VM → 进 VM 跑 setup 装工具链。macOS 13+ / Apple Silicon 或 Intel 都行，耗时约 10-15 分钟（主要是 Debian cloud image 下载 + apt 装包）。

想换 VM 名字（或起第二个 VM 测试）：

```bash
curl -fsSL https://raw.githubusercontent.com/blurname/df/master/debian/install.sh | bash -s -- mydev
```

注意 `-s --` 把后面的参数传给脚本，不是 bash 自己。

装完后以后开机：

```bash
limactl shell deb13
```

## 装了什么

- **apt**: git / neovim / tmux / fzf / ripgrep / fd / bat / jq / htop / btop / fastfetch / build-essential / python3 等 27 个包
- **外部二进制**: Node 22.19.0、pnpm、claude code、lazygit
- **Lima 配置**: Apple Virtualization + virtiofs + `~/git` 可写

脚本幂等，可重复运行。

## 自定义

- **改 cpu / mem**：编辑 `debian/lima/deb13.yaml` 里的 `cpus` / `memory`，`limactl stop/start`
- **加可写目录**：在 `mounts:` 下追加 `- location: "~/foo"` + `writable: true`
- **改 Node 版本**：改 `setup.sh` 顶部 `NODE_VERSION` 再重跑

## 端口转发

VM 里 `bun dev` / `pnpm dev` 监听的端口自动 forward 到 Mac localhost，浏览器直接 `http://localhost:<port>`。

## docker（按需手动）

脚本没自动装 docker（Debian 13 arm64 下官方脚本会拉 `docker-model-plugin` 等不稳定的新插件）。需要时：

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# 退出重进 shell
```
