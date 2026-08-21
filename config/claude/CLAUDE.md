# Global Instructions

## Git Commits

- Do NOT add Claude as a co-author in commit messages. No `Co-Authored-By: Claude ...` lines.

## 写代码

- **不要写注释**。代码自己说清楚：命名、拆函数、早返回。默认一行注释都不加
- 例外只有两种：用户明确要求写注释；或者存在无法从代码读出的外部约束（上游 API 的坑、必须保留的兼容行为、绕开某个 bug 的原因），这时写 WHY，不写 WHAT
- 不要改动/删除已有的注释，除非那段代码本身在改
