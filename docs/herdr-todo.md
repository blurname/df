# Herdr TODO

用于记录本机 Herdr 使用过程中发现的需求、bug 和后续可跟进项。

## 已完成

- Git 分支自动命名 tab
  - 独立插件仓库：`~/prj/herdr-git-tab-name`
  - GitHub：`blurname/herdr-git-tab-name`
  - 插件 id：`blurname.git-tab-name`
  - 当前已安装并启用。
  - 手动刷新键：`prefix+g`
  - 非 Git repo 的处理策略：不强行改名，避免把 tab 名改成空值或无意义内容。

- Herdr 配置纳入 df
  - 归档位置：`config/herdr/config.toml`
  - 实际生效位置：`~/.config/herdr/config.toml`
  - `config/.gitignore` 已允许跟踪 `config/herdr/`，但忽略 `config/herdr/plugins/`。

- Herdr plugin 编写文档
  - 文档：`docs/herdr-plugin-authoring.md`
  - 覆盖 manifest、action、hook、安装、发布、GitHub marketplace 索引规则。

## 待跟进

- 输入法自动切换 bug
  - 现象：使用微信输入法时，按下 prefix 后切到 ABC；完成动作后曾恢复到了搜狗输入法。删除搜狗输入法后，出现无法恢复回微信输入法的问题。
  - 当前配置：`switch_ascii_input_source_in_prefix = false`
  - 本机验证：macOS TIS API 能手动从 ABC 切回 `com.tencent.inputmethod.wetype.pinyin`。
  - 判断：更像 Herdr 0.7.1 的 experimental prefix 输入法恢复逻辑保存了 stale/wrong previous source，或者某些退出 prefix 的路径没有正确 restore。
  - 后续：如果要修，需要在 Herdr upstream 最小复现，重点看 prefix/navigate mode 进入退出时的 `PrefixInputSource` restore 时机。

- zellij 风格 sticky prefix
  - 需求：按一次 prefix 后，后续连续按键都走 Herdr，不要每次动作后退出 prefix，方便连续切换浏览。
  - 已尝试：使用 Herdr 内置 Navigate 模式，绑定 `workspace_picker = ["prefix+p", "prefix+space"]`，并显式配置 `navigate_pane_* = h/j/k/l`。
  - 结果：连续切 pane 可用，但体验不好；tab/workspace 等动作仍会退出 Navigate mode。
  - 判断：plugin 做不到完整 sticky prefix，因为 plugin 收不到并接管底层 key mode；需要改 Herdr 本体。
  - 后续：如要实现，应给 Herdr 增加 sticky prefix / persistent command mode 配置，而不是写 plugin。

- agent panel 隐藏 workspace name
  - 现象：左侧 `agents` 面板在多 tab workspace 下显示为 `<workspace name> · <tab name>`，例如 `voyager-1 · master`、`voyager-1 · main`。
  - 需求：不想每行都显示 workspace name，只显示 tab name / branch name；下方仍显示 `idle · claude/codex`。
  - 当前判断：Herdr 0.7.1 没有配置项控制这个 label 拼接。`agent_panel_sort` 只能控制排序，不能控制展示上下文。
  - 源码位置：`src/ui/sidebar.rs` 的 `AgentPanelEntry.primary_label` 和 `format_agent_panel_primary_label`；`src/workspace/aggregate.rs` 会提供 tab label。
  - plugin 限制：插件只能改 workspace/tab/pane/agent 名字，不能控制 sidebar 渲染格式。
  - 后续：建议 upstream 增加配置，例如 `ui.agent_panel_context = "workspace_tab" | "tab" | "workspace"`，或 `ui.agent_panel_hide_workspace = true`。

## 暂缓

- Herdr Navigate 模式自定义继续打磨
  - 当前先保留配置不动。
  - 如果后续继续试，可以考虑更换入口键或直接改成 prefix-free direct chord，但要避开终端、shell、编辑器已有快捷键。
