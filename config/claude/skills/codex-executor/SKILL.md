---
name: codex-executor
description: 用 GPT 监督与独立 DeepSeek Codex 实施会话完成多步骤代码开发、修复和重构。需要实际实施且任务适合拆分时自动采用，无需用户点名模型或会话；单步小改、纯问答、只读查询和用户要求亲自处理时不启用。
---

# Codex Executor

## 分工与边界

当前 GPT 会话负责澄清目标、制定任务、审查 diff、验证结果和向用户汇报。独立 Codex 会话默认使用 OpenDesign 的 `deepseek-v4.1-flash` 实施。用户另有指定时遵从用户，不修改主控模型、登录或全局默认 provider。

本 skill 允许为当前任务委派独立执行会话，不代表允许并行修改同一批文件、递归委派或扩大原任务权限。执行会话不得再次调用本 skill 创建执行器。沿用仓库文档、已有修改和用户审批边界；未授权则不得提交、推送、发布或做破坏性清理。不要通过关闭 sandbox、审批或 hooks 让执行器跑起来。

原生子代理不能独立覆盖父会话的 provider，因此这里使用独立 Codex 进程，而不是把 DeepSeek 模型名传给原生 spawn 工具。

## 准备与交接

- 先确认当前主控线程 UUID、项目绝对路径和 Git worktree。线程 ID 取当前会话的可信元数据，不用最新历史记录或 Rex block ID 猜测；取不到时改为读取执行器输出，不发回调到不确定的线程。
- 优先复用本任务已记录的执行线程；不要仅因模型相同就复用其他任务的会话。
- 优先使用 `OPENDESIGN_API_KEY` 环境变量；未导出时，可复用本机 `~/.dsh/.credentials.yaml` 的 `refs.OPENDESIGN_API_KEY` 字符串。使用 YAML 解析器在启动器进程内读取，只通过子进程环境传入，不拼入命令行、不打印、不写交接文件、不复制 auth 文件，也不永久修改 shell 配置。两处都缺少时提示用户在本机配置，不要求把 Key 发到聊天，不悄悄换到其他 provider。
- 在项目约定的位置建立任务交接目录；没有约定则使用独立的 `/tmp/codex-executor-<任务标识>/`。目录权限设为仅用户可访问。
- 写 `task.md`：目标、允许修改范围、禁止事项、已有修改、验收要求、项目路径、主控 UUID（若已确认）、回报文件位置。执行器必须重新读取适用的项目文档，不假设共享主控的对话、工具或权限。
- 用 `state.json` 记录主控和执行线程 UUID、项目路径、provider、model、交接目录和当前状态；不记录凭据。建立执行线程后从实际输出确认 UUID，不使用 `--last`。

## 启动执行会话

先检查本机 `codex exec --help`、`codex exec resume --help` 和 `codex queue --help` 是否仍支持所用参数。

先读取 `~/df/docs/dsh.md`、`~/df/config/dsh/profiles/dsh-tui/cordis.patch.yml` 和 `~/df/config/dsh/tui/model.json` 核对现有配置，只读取需要的字段，不输出凭据。DSH 配置使用 `openai-completions`，但已于 2026-11-18 在本机 Codex CLI 0.169.0 实测：`/models`、`/chat/completions` 和流式 `/responses` 均返回 200；独立 `codex exec` 使用此 provider 与模型成功调用 shell 并返回 `CODEX_OPENDESIGN_TOOL_OK`。因此当前地址可直接使用 `wire_api="responses"`，不需要转换代理。地址、模型或运行版本变化后，做只读最小工具调用验证，不凭 DSH 的协议字段断定 Codex 不兼容。验证失败时说明阻塞，不自动搭代理或换工具。

执行器配置由 `~/df/config/codex/executor.config.toml` 管理，通过 `~/.codex/executor.config.toml` 软链接安装。默认主配置保留本机 App 的运行态，不为执行器修改它。先确认 profile 链接存在；缺少时只安装这一条链接，不运行全量配置重建脚本。

启动使用 `codex --profile executor exec -C <项目路径> --json -o <交接目录>/result.md '<读取 task.md 的提示>'`；恢复使用 `codex --profile executor exec resume <执行线程UUID> '<后续任务或交接路径>'`。凭据由启动器进程按前述规则注入。初始提示要求完整读取 `task.md` 并执行。持久化会话供后续续接，不加 `--ephemeral`。不要把敏感背景或无关历史整批发送给外部 provider；只交付任务必要信息。

普通有限任务可直接用执行工具启动并等待；需要常驻或可见终端时读取 Rex skill，并按用户的项目 Tab 归属校验规则在同一 Tab split，绝不直接继承旧 Rex IDs 或默认新建 Tab。

首次实际任务确认请求到达目标 provider、返回工具调用且执行线程使用正确模型。Codex 可能警告未找到模型 metadata；该警告在只读实测中未阻止工具调用，但上下文上限等仍须依据网关模型信息核实，不能把 fallback metadata 当作准确规格。网络、认证、模型或协议失败先报告具体错误，不静默切换 provider，也不无限重试。不要套用 OpenCode Go 的端点、订阅或隐私区域配置；它不是本任务使用的 provider。

## 双向通信与续接

任务正文和结果放文件，消息只传摘要、状态和文件路径，不把长日志塞进队列。主控下发 `task.md` 或 `review-<轮次>.md`；执行器回写 `result.md` 或 `checkpoint-<轮次>.md`，包含实际改动、验证结果、未完成项和阻塞。

对已运行的线程通知：

```sh
codex queue --thread <接收线程UUID> --message '请读取 <交接文件绝对路径>；本轮任务范围与约束见文件。'
```

`queue` 使用接收线程已有模型，不能用它切模型。队列投递成功只代表已排队，不代表接收方读过或完成。不要在投递成功但唤醒失败时再次投递相同任务。

- 线程仍有 active writer：只 queue，不另开 writer，不强制恢复，也不抢锁。
- 独立 `codex exec` 本轮已退出：在原项目目录用 `codex exec resume <执行线程UUID> '<后续任务或交接路径>'` 并带上 `--profile executor`，继续原会话。不要假设 queue 能自动运行一个已经退出的 exec 进程。
- `queue --resume` 仅用于确认由对应 daemon 管理的线程；它可能排队成功而恢复失败，须分别核对，不把失败当作重建会话的理由。
- 执行器可以 queue 通知主控，但回调不可用时仍须落盘回报；主控也可读取 exec 输出，不依赖回调才能结束任务。

不要每写一个函数就设置等待点。按可审查的完整任务交付；只有范围不清、涉及额外授权、存在阻塞或主控明确要求时暂停。主控审查实际 diff、保护原有修改并运行与风险相称的独立验证；不把执行器自报通过当作已验收。需要修正时续接同一执行线程。完成后汇总结果和遗留问题，不擅自删除会话或交接证据。

## 主控向用户汇报进度

派活时在当前用户对话说明任务范围和验收点。任务尚未结束且主控会话运行期间，默认每 5 分钟主动发一条进展；用户指定间隔时以用户为准。用实际经过时间计算，等待执行器或测试时分段等待，单次等待不超过距下次汇报的剩余时间。无需暂停执行器等用户回复。

每次先查看最新执行事件、交接文件或测试输出，用一两句话说清已确认的进展、当前在做什么和下一步。没有新证据也按时说明，例如“过去 5 分钟没有新输出，最后确认的是类型检查通过，集成测试尚未返回”；不猜完成百分比。遇阻、需要用户决定或提前完成就立即报告，不等下个时间点。最终验收后停止汇报，不另设后台定时任务。

## 依据

- [Codex 子代理配置边界](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- 本机 provider 与模型依据：`~/df/config/dsh/profiles/dsh-tui/cordis.patch.yml`、`~/df/config/dsh/tui/model.json`；凭据与同步边界见 `~/df/docs/dsh.md`。

遇到版本差异只核查相关官方文档与本机 CLI，不为运行 skill 自动升级工具或重配整个环境。
