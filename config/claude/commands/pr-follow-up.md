在指定 PR 的分支上直接改代码并推送。PR 是别人提的,后续改动由用户负责 —— **已授权:切分支、改代码、commit、push 全部直接做,不要再问权限相关的问题**。

## 前提

- 用户会在 `$ARGUMENTS` 里贴 PR 链接或 PR 号。没给就按当前分支推断(`gh pr view --json number,url`);都拿不到就要一个链接,别猜。
- **不需要问的**:能不能改这个 PR、能不能 push 到别人的分支、要不要另开分支或提新 PR —— 答案一律是"直接在 PR 自己的分支上改、往回推"。
- **需要停下来的**只有真障碍:工作区有未提交改动、push 被远端拒绝、仓库检查跑不过。这些说清楚现状再让用户决定。

## 1. 切到 PR 分支

先确认工作区干净,再切分支:

```sh
git status --porcelain          # 有输出就停下来告诉用户,不要自作主张 stash / discard
gh pr checkout <PR-URL 或号>    # fork 的 PR 也能处理,会配好 push 用的 remote
```

记下 PR 信息备用:

```sh
gh pr view --json number,title,url,headRefName,baseRefName,isCrossRepository,author
```

`isCrossRepository=true`(fork 过来的 PR)时 push 目标是作者的 fork,需要作者勾了 "Allow edits by maintainers"。不用提前确认,push 真报 403 再按第 5 节处理。

## 2. 确定要改什么

- 用户已经说清要改什么 → 照做。
- 没说清 → 先按 `/pr-comments` 的第 2、4 节抓取并分析评论,把未解决的 `必改` 项当成待办清单,再动手。做之前用一句话说明你打算改哪几条。

## 3. 改代码

- 就在 PR 分支上改,不新建分支。
- 只覆盖用户要求 / 评论指出的范围,不顺手重构无关代码。
- 跟着这个 PR 和周围代码已有的风格走(命名、错误处理、注释密度),不引入新模式。
- 改完跑仓库自己的检查:测试 / lint / typecheck(去 README、package.json、Makefile、CI 配置里找)。跑不过先修,不要带着红灯提交。

## 4. 提交

- commit message 跟着仓库现有风格(`git log --oneline -20` 看一眼),别自创格式。
- 一个 commit 一个主题,别把无关改动塞进同一个 commit。

## 5. 推送

```sh
git push        # gh pr checkout 已配好 upstream,正常情况直接推
```

- **默认不要 force push**。确实需要改写历史(rebase / amend)时用 `git push --force-with-lease`,并在回复里说明原因。
- 推不上去时:
  - 远端有新提交 → `git pull --rebase`,重跑检查,再推。
  - 403 / 分支保护 / fork 没开 maintainer edits → 说明具体原因和可选做法(比如改从自己的分支另提 PR),交给用户定夺。

## 6. 收尾

推送成功后汇报:改了哪些文件、commit hash、推到了哪个 remote/分支、仓库检查跑了什么结果。

若本次改动解决的是已授权评审者(名单见 `~/.claude/pr-reviewers.local`)的行内评论,按 `/pr-comments` 第 5 节对相应 thread 自动 reply + resolve。
