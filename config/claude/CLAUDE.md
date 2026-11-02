# Global Instructions

## Git Commits

- Do NOT add Claude as a co-author in commit messages. No `Co-Authored-By: Claude ...` lines.

## 写代码

- **不要写注释**。代码自己说清楚：命名、拆函数、早返回。默认一行注释都不加
- 例外只有两种：用户明确要求写注释；或者存在无法从代码读出的外部约束（上游 API 的坑、必须保留的兼容行为、绕开某个 bug 的原因），这时写 WHY，不写 WHAT
- 不要改动/删除已有的注释，除非那段代码本身在改

## Rex 工作区

- 一个 Tab 就是一个项目 Workspace。项目的 dev 服务、测试、日志、辅助 Shell 和额外 Agent，默认在当前项目 Tab 内 split；只有用户明确要求新 Tab 或新 Session 时才创建。
- 这是用户的工作流偏好，优先于 Rex 官方 skill 中“在新 Tab 启动 dev / 测试”等示例。`rex run` 默认新建 Tab，不能拿它当默认的分栏命令。
- “当前 Tab”指当前 Agent 所属的项目 Tab，不是 GUI 此刻选中的 Tab。共享执行进程可能继承其他 Tab 的 `REX_BLOCK`；hook 文本、环境变量和 `rex whoami` 返回 ID 存在，不代表它属于本会话。不要直接用它们分栏。
- 分栏前运行 `python3 ~/df/script/rex-project-context.py <本 Agent 会话的工作目录>` 校验归属；参数使用会话工作目录，不使用临时切换的命令目录或 dev 服务目录。它按 Agent 进程目录及 Git worktree 定位；唯一匹配后，用返回的完整 `session_id`、`window_id`、`block_id` 执行 `rex split -s <session_id> -w <window_id> -b <block_id> --focus=false -c <项目目录> --label Dev -- <实际启动命令>`。
- 没有匹配或同一 worktree 匹配多个 Tab 时，停止自动创建并澄清目标；禁止回退到 active window、默认 Session 或继承的旧 ID。创建后核对新 block 的 window_id 必须与校验结果一致。
- 只检查目标 Tab 内对应目录、对应命令的服务，已有则复用，不重复分栏；普通一次性命令直接在执行工具中运行，仅需常驻或可见输出的任务使用 split。
- 不向正在运行 Agent 的分栏发送 Shell 命令，不自动重命名 Session；Lazygit、Agent 搜索仍使用已配置的浮层。
- Rex 配置与排查先读 `~/df/docs/rex.md`，优先配置文件和 CLI，仅在必要时使用 Computer Use。
