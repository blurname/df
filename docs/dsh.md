# DSH（DeepSeek Harness）配置同步

更新日期：2026-11-08。适用于本机 dsh-tui 0.19（`~/.dsh/profiles/dsh-tui` 装的就是它）。

## 为什么不用软链

`script/01-link-config.ts` 里 `~/.claude`、`~/.codex` 那套是软链。DSH 这边不行，因为它的两个写入点都是「先写临时文件，再 `rename(2)` 覆盖」：

- profile 补丁 `cordis.patch.yml`：`dsh-config-editor` 走 `writeFileAtomic`
- TUI 偏好 `~/.dsh-tui/settings.json`：`writeTuiSettings` 写 `.tmp` 后 `renameSync`

`rename` 会把软链换成新的普通文件，看起来配置还在，实际同步静默断掉。既然有几个文件
不能软链，这里就统一用 `script/dsh-config.ts` 双向复制，避免两套心智模型。

## 同步范围

| 本地路径 | 仓库路径 |
| --- | --- |
| `~/.dsh/profiles/dsh-tui/cordis.patch.yml` | `config/dsh/profiles/dsh-tui/cordis.patch.yml` |
| `~/.dsh/profiles/web/cordis.patch.yml` | `config/dsh/profiles/web/cordis.patch.yml` |
| `~/.dsh/profiles/headless/cordis.patch.yml` | `config/dsh/profiles/headless/cordis.patch.yml` |
| `~/.dsh-tui/settings.json`（`/settings` 用户层：语言等） | `config/dsh/tui/settings.json` |
| `~/.dsh-tui/theme.json`（`/theme`） | `config/dsh/tui/theme.json` |
| `~/.dsh-tui/effort.json`（`/effort`） | `config/dsh/tui/effort.json` |
| `~/.dsh-tui/model.json`（`/model` 记住的 provider+model 路由） | `config/dsh/tui/model.json` |

**不进仓库**：

- `~/.dsh/.credentials.yaml`：登录凭据（含 token），仓库是公开的；新机器重新登录即可。
- `~/.dsh/sessions`、`~/.dsh/storages`：会话与索引。
- `~/.dsh/profiles/*/{package.json,pnpm-lock.yaml,node_modules}`：由 dsh 安装/升级维护。
- `~/.dsh-tui` 的 `model-recents.json`（模型列表历史）、`history.jsonl`、
  `last-run.json`、`compile-cache/` 等运行态。
- `~/.dsh-tui/lang.json`：和 `settings.json` 的 `values.lang` 重复，后者已是用户层。

模型路由本身写在 profile 补丁里（本机 `web` 那份 pin 了 `deepseek-account` + `deepseek-flash`
+ `reasoningEffort: high`）；`/provider` 加的密钥写入 `.credentials.yaml`，同样不外传。

## 用法

```sh
bun script/dsh-config.ts status      # 看哪些路径有差异
bun script/dsh-config.ts push        # 本机 → 仓库（改完设置后）
bun script/dsh-config.ts pull        # 仓库 → 本机（新机器）
```

也走 npm：`bun run dsh-status`、`bun run dsh-push`、`bun run dsh-pull`。加 `-n` / `--dry-run`
只打印不写盘。`pull` 覆盖前会留 `<文件>.before-dsh-pull-<时间戳>` 备份。

### 新机器

1. 安装 dsh-tui，**先启动一次**，让它生成 `~/.dsh/profiles/{dsh-tui,web,headless}`。
2. `bun script/dsh-config.ts pull`。
3. 重新登录 DeepSeek 账号（凭据不入库）。

## 退出时自动 push（已启用）

`config/.zshrc` 末尾给 `dsh-tui` 套了一层包装，TUI 退出后自动把配置复制进仓库：

```sh
dsh-tui() {
  command dsh-tui "$@"
  local rc=$?
  bun ~/df/script/dsh-config.ts push >/dev/null
  return $rc
}
```

- `command` 绕过函数本身，避免递归；`local rc` 保住 TUI 的退出码。
- 只吞 stdout，push 失败时 stderr 仍会打出来，不会静默断同步。
- 脚本逐字节比较，没改就不写盘；它只更新工作区文件，**不会 commit，也不会
  `git push`**，提交前照常看一眼 `git status`。
