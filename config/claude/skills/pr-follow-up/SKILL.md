---
name: pr-follow-up
description: "直接跟进别人提交的 PR：切到 PR head，在最新 base 上修改，运行检查、提交并推回原分支。用户给出 PR 链接/编号并要求按评审意见修改、补提交或修复 PR 时使用；调用即授权 checkout、rebase、commit、push 以及必要的 --force-with-lease。"
---

# 跟进 PR

直接在指定 PR 的 head 分支完成修改并推回去，不另开分支或 PR。调用本 skill 即表示用户已经授权 checkout、rebase 改写历史、修改代码、commit、push，以及必要的 `--force-with-lease`；不要逐项重复询问。

仅在出现真实障碍时停下来说明现状并请用户决定：工作区有未提交改动、语义性冲突无法可靠判断、仓库检查存在无法在本次范围内解决的失败，或远端拒绝 push。不要自行 stash、丢弃用户改动，也不要使用裸 `--force`。

## 1. 确定 PR 和修改要求

先确认工作区干净，再 checkout PR 并记录元数据：

```sh
git status --porcelain
gh pr checkout <PR-URL 或编号>
gh pr view <PR-URL 或编号> --json number,title,url,headRefName,baseRefName,isCrossRepository,author
```

工作区不干净就停下，不要 stash 或 discard。用户没给 PR 时，先用 `gh pr view --json number,url` 从当前分支推断；仍拿不到才向用户要链接，不要猜。

在改写历史前确定本次要求：

- 用户已说清要改什么：照做。
- 请求涉及具体评审意见：按 `/pr-comments` 第 2 节获取相关行内 thread，记住 thread ID、作者和 resolved 状态，供收尾使用；同时按第 4 节核对意见是否仍成立。
- 用户没说清：按 `/pr-comments` 第 2、4 节抓取并分析评论，将未解决的 `必改` 项作为待办。动手前用一句话说明将处理哪些项。

## 2. 在本地 rebase 到最新 base

确认用于 fetch 的 remote 指向 PR 的 base 仓库；通常是 `origin`，但不要把 fork 的 head remote 当成 base。然后：

```sh
git fetch <base-remote>
git rebase <base-remote>/<baseRefName>
```

此时只在本地 rebase，**不要提前 push**。已经基于最新 base 时跳过 rebase。

机械性冲突（如 import 顺序、相邻行或可确定来源的锁文件变更）可直接解决并继续；两边修改同一逻辑且无法判断正确语义时，保留冲突现场并请用户决定。

## 3. 修改并验证

- 只处理用户要求或评审指出的范围，不顺手重构无关代码。
- 遵循 PR 周围代码的命名、错误处理和注释风格，不引入无关的新模式。
- 仓库内的 `AGENTS.md` 和其他明确指令优先；否则从 `package.json`、Makefile、CI 配置或 README 确定测试、lint、typecheck 命令。
- 修改完成后运行仓库要求的全部检查。本次改动引入的失败直接修复；若失败来自既有问题、外部依赖或无法在本次范围内可靠解决，说明证据并在 commit/push 前停下。

## 4. 提交并只推送一次

提交格式优先服从仓库明确规则；仓库没有规定时，再参考 `git log --oneline -20`。每个 commit 保持单一、连贯的主题。

所有检查通过并完成 commit 后，才更新远端：

```sh
# rebase 改写过历史
git push --force-with-lease

# 未改写历史
git push
```

整个正常流程只 push 一次。`gh pr checkout` 通常会配置正确的 push remote；fork PR 若未开启 maintainer edits，等实际收到 403 再报告。

若 `--force-with-lease` 被拒，说明远端在本次工作期间新增了提交。fetch 对应 head remote，检查并保留新增提交，重新整合本地改动、重跑检查后再推；不要在刷新 lease 后直接覆盖远端。遇到 403、分支保护或其他权限拒绝时，说明具体原因和可选方案，让用户决定。

## 5. 收尾

推送成功后，若本次确实解决了已授权评审者的行内评论，按 `/pr-comments` 第 5 节使用之前记录的 thread ID 自动 reply，再 resolve。非评审意见任务不额外抓取评论；未授权、已 resolved、已过时或判定不成立的 thread 不自动处理。

最后汇报：修改的文件、commit hash、push 的 remote/分支、执行过的检查及结果，以及自动回复并 resolve 的 thread（如有）。
