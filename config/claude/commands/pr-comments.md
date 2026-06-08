拉取并整理当前 PR 的所有评论。**只读：绝不发表、回复、编辑、resolve、approve 或以任何方式改动 PR。**

## 硬约束(只读)

- 只用读取类命令:`gh pr view`、`gh api`(仅 GET)、`gh api graphql`(仅 query)。
- **禁止**任何写操作:不要 `gh pr comment` / `gh pr review` / `gh pr edit` / `gh pr close`,不要 `gh api -X POST/PATCH/PUT/DELETE`,不要 resolve / unresolve review thread。
- 不改动工作区文件,不 commit,不 push。本命令的产物只是给用户看的整理结果。

## 1. 确定目标 PR

- 用户在 `$ARGUMENTS` 里给了 PR 号或 URL → 用它。
- 否则按当前分支推断:`gh pr view --json number,title,url,state -q .`。若当前分支没有关联 PR,直接告诉用户并停止(不要去猜)。

先拿到 owner / repo / number 备用:

```sh
gh repo view --json owner,name -q '.owner.login + "/" + .name'
gh pr view ${ARGS:+$ARGS} --json number -q .number
```

## 2. 抓取三类评论

GitHub PR 的评论有三个来源,要全抓:

1. **行内 review 评论**(挂在代码某行上,带 resolved 状态)—— 用 GraphQL 才能拿到 `isResolved` / `isOutdated`:

```sh
gh api graphql -f query='
query($owner:String!,$repo:String!,$number:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{
          isResolved isOutdated path line
          comments(first:50){nodes{author{login} body createdAt diffHunk url}}
        }
      }
    }
  }
}' -F owner=OWNER -F repo=REPO -F number=NUMBER
```

2. **Review 汇总**(APPROVED / CHANGES_REQUESTED / COMMENTED 及其正文):
   `gh api repos/OWNER/REPO/pulls/NUMBER/reviews --paginate`

3. **会话区评论**(PR 时间线上的普通讨论):
   `gh pr view NUMBER --comments`,或 `gh api repos/OWNER/REPO/issues/NUMBER/comments --paginate`

分页较多时记得 `--paginate`。

## 3. 整理输出

按对用户有用的顺序呈现,不要原样倒数据:

- 顶部一行 PR 标题 + 状态 + 链接。
- **未解决的行内评论优先**,按文件分组;每条给出 `文件:行`、作者、时间、正文,必要时附 diffHunk 片段和评论链接。
- 已 resolved / outdated 的折叠成简短列表(数量 + 一句话),除非用户要求展开。
- Review 汇总单独一段:谁 approve、谁 request changes、附其评论。
- 会话区评论单独一段。

若没有任何评论,明确说"无评论"。

## 4. 分析评论

整理之后逐条分析,这一步也只读 —— 可以打开 `文件:行` 读真实代码来判断,但**不修改、不应用任何改动**。

- **分类**:给每条未解决评论打标 —— `必改`(正确性/bug/安全)、`建议`(可选改进)、`挑剔`(风格/命名)、`提问`(需要回答而非改代码)、`已过时`(代码已变,评论不再适用)、`认可`。
- **判定有效性**:读对应代码确认评论是否成立、是否仍适用。明确指出"评论说得对" / "评论已被后续提交解决" / "评论基于误解,理由是…"。不要默认 reviewer 一定对。
- **归类主题**:把反复出现的关注点聚成几条(如"多处缺错误处理"、"命名不一致"),避免逐条孤立。
- **冲突**:指出 reviewer 之间相互矛盾的意见,交给用户定夺。
- **优先级 / 阻塞**:区分"挡住合并的"和"可选的";若有 CHANGES_REQUESTED,点出具体要解决哪几条才能转 approve。

输出一份精简结论:按 `必改 → 建议 → 提问 → 可忽略` 排好的待办清单,每条附 `文件:行` 和一句话理由。仅给建议,不替用户动手改、回复或 resolve。
