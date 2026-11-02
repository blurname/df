# Rex 配置与使用约定

更新日期：2026-11-02。适用于本机 Rex Beta 0.1.0（1642）；升级后以本机 CLI 和官方文档为准。

## 修改配置时的操作要求

**优先修改配置文件、使用 Rex CLI / API，不要默认使用 Computer Use。**

- 先读仓库现有配置，再通过 `rex help`、`rex actions`、`rex api describe` 确认能力和参数。
- 快捷键、浮层、事件脚本、Git 分支标签、Session 和 Tab 管理，优先在终端完成。
- GUI 设置也先查是否有受支持的配置或命令行接口；不能仅因为界面上有开关就直接用 Computer Use。
- 只有配置与 CLI 无法完成的 GUI 操作，或确实需要检查视觉效果、界面焦点等问题时，才使用 Computer Use，并说明原因。
- 配置检查和 CLI 返回结果足以验证时，不额外打开界面重复检查。
- 用户已授权直接调整日常配置，不重复询问可逆配置修改；控制权限的授权与使用哪种工具是两回事，不能通过改用终端绕过必要的权限确认。
- 保留用户现有终端、运行中的任务和仓库无关改动；验证关闭操作时使用自己创建的临时终端。

## 官方文档

| 入口 | 用途 |
| --- | --- |
| [Rex 文档首页](https://www.superlogical.com/rex/docs/) | 总入口 |
| [Configuration File](https://www.superlogical.com/rex/docs/customize/config) | 配置位置、检查与重载 |
| [Keyboard Shortcuts](https://www.superlogical.com/rex/docs/customize/keyboard-shortcuts) | 快捷键与动作发现 |
| [Custom Actions](https://www.superlogical.com/rex/docs/customize/actions) | Lua 自定义动作 |
| [The CLI](https://www.superlogical.com/rex/docs/automate/cli) | 命令、目标 ID、JSON 输出与对象层级 |
| [Lua Scripts](https://www.superlogical.com/rex/docs/automate/lua-scripts) | 独立脚本与外部命令 |
| [Lua Events](https://www.superlogical.com/rex/docs/automate/lua-events) | 事件监听、定时器与运行方式 |
| [Lua API](https://www.superlogical.com/rex/docs/reference/lua) | API 与可用执行环境 |
| [Events](https://www.superlogical.com/rex/docs/reference/events) | 事件名称、字段与作用范围 |
| [Agents](https://www.superlogical.com/rex/docs/automate/agent-skill) | Agent 集成与 Remote Control |
| [Program Status Protocol](https://www.superlogical.com/rex/docs/build/program-status) | Agent 状态上报 |

## 本人的工作流

- **一个 Session 即可，一个 Tab 当一个项目 Workspace。** 不再默认给每个项目创建 Session。
- 关闭 Agent 自动命名 Session，不随任务改名。2026-11-01 已将 `rex.agents.names-sessions` 设为 `false`，并通过 `rex skill setup --session-naming=false` 同步 Codex / Claude 的 skill 与启动 hook。今后重新安装集成时也保持关闭。
- Tab 直接使用项目名称，例如 `cluby`、`df`、`adx`。最初配置为左侧竖排，2026-10-31 用户在 GUI 改成顶部横排、字号 19 pt；保留用户后续的布局选择。
- 项目内需要同时查看的 Agent、Shell、开发服务放在该 Tab 的分栏中。
- dev、测试、日志、辅助 Shell 和额外 Agent 默认在当前项目 Tab 内 split，只有用户明确要求时才新建 Tab / Session。先检查并复用已有服务，避免重复启动。
- Lazygit 和 Agent 搜索用临时浮层，不长期占用分栏空间。
- 界面尽量简单：关闭动效，使用 Compact panes，隐藏 pane headers，Tab 图标数量为 0。
- 当前主 Session 名为 `main`。Rex CLI/API 中的 `window` 指 Session 内的 Tab，不等于 macOS 应用窗口。
- Herdr 是现有工作流的参照；不要再按 Zellij 的使用方式推断需求。

## 配置位置

| 文件或位置 | 内容 |
| --- | --- |
| [config/rex/init.lua](../config/rex/init.lua) | 快捷键、ADX 浮层、自定义动作 |
| `~/.config/rex/init.lua` | 指向上述文件的软链接 |
| [config/rex/git-tabs.lua](../config/rex/git-tabs.lua) | 左侧 Tab 的 Git 分支标签 |
| [script/setup-rex-git-tabs.py](../script/setup-rex-git-tabs.py) | 安装并启动 Git 标签后台脚本 |
| [script/01-link-config.ts](../script/01-link-config.ts) | 配置软链接清单 |
| [config/rex/Muted Light.ghostty](../config/rex/Muted%20Light.ghostty) | 终端配色 |
| [config/.zshrc](../config/.zshrc) | Rex CLI 路径和 TERM 环境处理 |
| [Karabiner 配置](../config/karabiner/assets/complex_modifications/windows-like-macos.json) | 内置与外接键盘的修饰键映射 |
| macOS 偏好域 `com.superlogical.rex` | 客户端外观设置；未全部纳入 Lua 配置 |

日常只改相关文件，不为了更新 Rex 而运行会重建所有软链接的脚本。

## 快捷键

Lua 中的前缀是 ``alt+`>``。结合当前 Karabiner 映射，实际操作为：

- Mac 内置键盘：**左 Command + 反引号（`）**。
- 外接键盘：**左 Alt + 反引号（`）**。
- **按完前缀后全部松开，再按下表操作键。** 不要一直按住修饰键。

| 操作键 | 功能 |
| --- | --- |
| `T` | 新建 Tab / Workspace |
| `H` / `L` | 上一个 / 下一个 Tab |
| `1`～`9` | 切到对应位置的 Tab |
| `R` | 重命名 Tab |
| `W` | 关闭当前分栏 |
| `Shift+W` | 关闭整个 Tab，包含其分栏 |
| `N` / `Shift+N` | 向右 / 向下分栏 |
| `J` / `K` | 下一个 / 上一个分栏 |
| 方向键 | 按方向切换分栏 |
| `F` | 放大 / 恢复当前分栏 |
| `Shift+F` | 当前分栏浮动 / 停靠 |
| `G` | Lazygit 浮层 |
| `A` | Agent 搜索浮层 |
| `I` | Caress 浮层 |
| `Shift+T` | 临时浮动 Shell |
| `=` | 调整大小模式：方向键调整，`Shift` 加速，`=` 均分，Enter 或空格退出 |

仍保留 `M` 新建 Session、空格切换 Session、逗号/句号切换 Session 的旧绑定，但日常项目管理使用 Tab。

## 浮层与 Agent 跳转

### Agent 启动 dev / 测试的默认位置

Rex 官方 skill 的 dev 和测试示例使用新 Tab，这与本人的工作流不同。已在 [全局 Agent 指令](../config/claude/CLAUDE.md) 写入优先规则；该文件同时链接到 `~/.codex/AGENTS.md` 和 `~/.claude/CLAUDE.md`，不修改安装器管理的 Rex skill，以免升级覆盖。

2026-11-02 排查发现：本会话目录为 `~/df`，但执行工具继承的 `REX_BLOCK` 指向 `game` Tab 的 Agent。该 ID 存在，`rex whoami` 也返回它，因此仅验证 ID 存活不足以确认归属。不要把“当前 Tab”理解成 GUI 当前选择的 Tab，也不要直接信任共享执行进程继承的环境变量。

需要可见的开发服务终端时，先用 [项目 Tab 定位脚本](../script/rex-project-context.py) 校验。参数为本 Agent 会话的工作目录，不是临时命令目录或另一个 worktree 的 dev 目录：

```sh
python3 ~/df/script/rex-project-context.py /Users/bl/df
```

脚本只读取 Rex 状态，按 Agent 进程目录及 Git worktree 匹配，返回完整 `session_id`、`window_id`、`block_id`。没有匹配或匹配多个 Tab 时会报错，不能回退到当前选中 Tab。若同一个 Tab 有多个同项目 Agent，优先使用其中匹配的继承 block，否则选择该 Tab 中一个匹配的 Agent 分栏。

把返回的完整 ID 传给 split；例如项目确实使用 `pnpm dev` 时：

```sh
rex split -s "$verified_session" -w "$verified_window" -b "$verified_block" --focus=false -c "$project_dir" --label Dev -- pnpm dev
```

`project_dir` 应是当前项目的绝对路径，启动命令以项目文档和脚本为准。先查看该项目 Tab 的现有分栏和进程；不要重复启动服务，也不要把命令发送到 Agent 自身分栏。`rex run` 默认会新建 Tab，日常辅助任务使用 `rex split`。

只复用目标 Tab 内目录和命令均匹配的服务。普通一次性检查直接通过执行工具运行，避免每次命令都创建分栏。创建后用 `rex block inspect` 检查新 block 的 `window_id` 与校验结果一致。已有错误位置的服务应先核对归属，再移动；不要关闭正在运行的用户任务。

全局指令在新 Agent 会话启动时加载；已经运行的其他会话可能需要再次明确告知“dev / 测试放当前 Tab 的 split”。

### 临时工具浮层

Lazygit 浮层调用 `adx git --dir .`，根据仓库根目录复用，同一 Session 内可跟随到其他 Tab。再次按前缀 → `G` 隐藏时保留进程；在 Lazygit 内退出则结束进程。

Agent 浮层由 ADX 提供，列出当前 Rex 服务里的 Agent，可搜索后按 Enter 跳转，Esc 关闭，Ctrl-R 刷新。ADX 实现位于本机 `~/prj/adx/internal/rex/rex.ts` 和 `~/prj/adx/app/adx/runtime/rex-agent.ts`。

**截至本次配置，Remote Control 未开启，Agent 跳转仍受此限制。** 实测直接修改服务端焦点不会让 macOS 客户端跟随；即使同一 Session 内跨 Tab，当前实现也需要客户端控制权限。浮层的 “between sessions” 错误提示范围不准确，不能据此认为同一 Session 内已可用。

开关位置是 Settings → Server → Remote Control。后续处理先确认配置接口和权限，再修改；不要为了验证自动打开此开关。关闭该权限不影响 Git 标签脚本改名。

## Git 分支标签

显示格式为 `Tab 名 · 分支`，例如 `adx · main`、`df · master`。Detached HEAD 显示短提交 ID；不在 Git 仓库时移除分支后缀。

脚本读取 Tab 当前选中的平铺终端；浮层打开时继续沿用之前的平铺终端。目录、进程、布局变化触发刷新，同时每 3 秒检查一次，因此 Lazygit 或 Agent 在后台切分支也能更新。该脚本读取本机仓库，不应假定能读取远端终端的仓库。

Git 分支后缀使用 ` · ` 分隔；手工命名时避免把相同格式当作自定义名称的一部分。

安装或更新脚本后重新启动：

```sh
python3 ~/df/script/setup-rex-git-tabs.py
```

它创建 `~/.config/rex/git-tabs.lua` 软链接和 `~/Library/LaunchAgents/com.bl.rex-git-tabs.plist`，登录后运行。修改 Lua 后需要重新启动后台脚本，`rex config reload` 只重载主配置。

查看运行状态和日志：

```sh
launchctl print "gui/$(id -u)/com.bl.rex-git-tabs"
tail -n 30 ~/Library/Logs/rex-git-tabs.log
```

## 修改后的验证

Rex 终端内通常已能直接使用 `rex`。其他终端可以指定本机应用附带的 CLI：

```sh
rex_bin='/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex'
"$rex_bin" config check
"$rex_bin" config reload
"$rex_bin" keymap
```

排查时先用 `client ls --json` 找到应用客户端，再通过 `-C <client-id> actions` 查客户端支持的动作；服务端 API 用 `api describe <method>` 查参数。GUI 行为不能仅凭服务端 API 返回成功就宣称验证通过。

事件监听和定时器放在独立的 `rex do` 脚本里；当前版本的 `init.lua` 不执行事件监听。参见 [Lua Events](https://www.superlogical.com/rex/docs/automate/lua-events)。
