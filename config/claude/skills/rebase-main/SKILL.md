---
name: rebase-main
description: "把当前分支上的所有 commit 压成一个,再 rebase 到最新的 origin 默认分支(main/master 自动探测)。**压缩是一次性的**:本 skill 跑完即结束,之后的任何新改动一律新建 commit,不许 amend / reset --soft 再 commit 折进去——用户之前说过 squash 不构成授权,唯一的授权信号是用户重新调用本 skill。当用户要求 squash commit、压缩提交、整理成一个 commit、rebase 到最新 main/master 时使用。"
---

把当前分支压成一个 commit,再 rebase 到最新的 origin 默认分支。

## 核心规则:压缩只发生在本次调用

**授权的边界就是这次调用本身。** skill 在 rebase(或 push)完成的那一刻结束。

之后,本会话里的任何新改动 —— 不管是用户提的新需求、review 意见、还是修自己刚写出的 bug —— **一律 `git commit` 新建 commit**。具体禁止:

- `git commit --amend`(把新改动折进上一个 commit)
- `git reset --soft HEAD~N` 之后再 commit
- `git rebase -i` / `git rebase --autosquash` / `git commit --fixup`

**"用户之前说过要 squash" 不构成理由。** 唯一的授权信号是**用户重新调用 `/rebase-main`** —— 那时候照常执行下面的流程,把分支上现有的一切(包括上次压出来的那个 commit 和之后的新 commit)重新压成一个,再 rebase 到最新 base。天然幂等,所以不需要任何"squash 模式"的开关,也不要自己发明一个。

**唯一例外**:纯改 commit message(工作区干净时的 `git commit --amend -m "..."`)不算把改动折进去,可以做。判据是有没有新的代码改动被并进那个 commit。

这条规则存在的原因:agent 听到一次 "squash" 之后,容易把它当成持续生效的模式,把后续每一次改动都继续折进同一个 commit。那不是用户要的。

## 0. 前置检查

```sh
git rev-parse HEAD              # 记下来!压缩前的 HEAD,出事就是靠它回滚
git branch --show-current
git status --porcelain
```

- **把压缩前的 HEAD hash 记住,收尾时报告给用户** —— `git reset --hard <原HEAD>` 能完整恢复,是这次操作唯一的后悔药。
- 当前在默认分支上(main/master)→ 停下来问,不要在主干上压历史。
- 工作区不干净 → 停下来问用户:这些改动是要一起压进去,还是先 stash?**不要自作主张 stash 或 discard。**

## 1. 探测目标分支

不要写死 `main`,仓库可能是 `master` 或别的:

```sh
git fetch origin
git symbolic-ref --short refs/remotes/origin/HEAD    # 例如 origin/master
```

这条报错(有些 clone 没设过)就先 `git remote set-head origin -a` 再试;还不行就看 `git branch -r` 里有 `origin/main` 还是 `origin/master`,都有就问用户。下面用 `<base>` 指代它。

## 2. 看清要压哪些

```sh
git merge-base HEAD <base>          # 记为 <mb>
git log --oneline <mb>..HEAD
```

- 0 个 commit → 没东西可压,只 rebase(或直接告诉用户没事可做)。
- 1 个 commit → **不需要压**,跳到第 4 步只做 rebase。别为了"执行完整流程"去 reset 一遍。

## 3. 压成一个

```sh
git reset --soft <mb>
git commit -m "<message>"
```

commit message:

- 用户调用时给了 → 直接用。
- 没给 → 看 `git log --oneline -20` 摸清仓库的 message 风格(前缀、语言),再从被压掉的那几条 subject 归纳一条。在回复里说清用了哪条,不用为这个卡住等确认 —— 事后单独改 message 是允许的(见核心规则的例外)。

## 4. rebase 到最新 base

```sh
git rebase <base>
```

先压后 rebase,所以冲突最多解一轮。冲突就正常解、`git rebase --continue`;解不动就 `git rebase --abort`,回到第 0 步记下的 HEAD,把情况告诉用户。

## 5. push(要先问)

分支没有 upstream 就跳过这步。有 upstream 的话,历史已经被重写,只能 force —— **推之前问用户一句**,不要默认推:

```sh
git push --force-with-lease
```

- 永远不用 `git push --force`(全局 settings 里也 deny 了)。
- `--force-with-lease` 被拒 = 远端有你本地没有的提交(别人推过东西)。**停下来说明情况**,不要升级成 `--force` 硬盖。

## 6. 收尾

报告:压了哪几个 commit → 新 commit hash 和 message、rebase 到了哪个 base、**压缩前的 HEAD hash(回滚用)**、推了没有。

然后在回复里显式写一句,例如:

> squash 已完成并结束。后续改动我会新建 commit,不会再折进这个 commit;要再压一次请重新调用 `/rebase-main`。

把这句话说出口是流程的一部分 —— 它落在可见的对话里,比留在这份文件里更难被后面的自己忽略。
