用 simplify 的标准再过一遍。**态度更新：能省就省，不要"够用就行"。**

## 自审盲区(优先警惕)

本次会话里**自己刚写或刚改的代码**有最高的复审优先级。常见盲区：

- 自己加的 `eslint-disable` / `eslint-disable-next-line` —— 不要默认它合理。先去 design tokens / shared utilities 里找语义化替代,搜不到再考虑 disable
- 自己加的 `key={someProp}` 用作 remount trigger —— 一般属于"应该在 caller 控制"的模式,放在组件内部隐含语义不清
- 自己加的 optional props —— 如果唯一 caller 总传同一个值,硬编码;不要为假想未来留口子
- 自己加的样式属性(`translateZ(0)` / `backface-visibility` / `font-smoothing`) —— 只有能说清楚 WHY 才留,说不出原因就删
- 自己加的"防御性代码"(`x || fallback`、`if (!x) return`) —— 看类型 / schema,如果上游保证 non-null,fallback 是死代码

## 单文件 / diff 内的检查

- 是否有不必要的 state/effect
- 是否有已有组件可复用
- optional 是否真的 optional(逐个 prop 检查唯一 caller 是否每次都传同一值)
- 昂贵操作是否延迟执行
- 存储 key 是否一致
- 能用平台能力的是否用了 JS 重新实现
- 是否有职责重叠的 state/ref(如 ref 和 state 做同一件事)
- 是否有永久阻塞的 guard 条件导致后续逻辑失效
- 是否有未使用的变量或 import

## DRY / 模式识别(LLM 容易漏)

- **重复 className 串**:相邻 JSX 元素的 className 大段相同,只差一两个 token —— 用 `cx`/`cn` 抽公共部分。看 conditional `? "a b c x" : "a b c y"` 模式立刻起反应
- **重复 inline 样式对象**:多个元素带同样 style block —— 抽常量或写到 CSS
- **多份相同字面量常量**:`grep` 看 codebase 其他地方有无相同字面值,≥2 处抽共享模块
- **17 行 `prose-*` / 长 Tailwind class 串**:看是否项目惯例放 css 文件(用 `@apply`)
- **8 个 keyframes / 大段 CSS-in-JS**:能不能挪进真正的 `.css` / `.svg` 资源

## z-index / 堆叠上下文

任何一个 `z-*` / `z-[N]`,都问一遍:
- 当前堆叠上下文里**真的有需要被压在它下面的兄弟**吗?
- 兄弟自身有没有更高的 `z-*`,使得本元素的 `z-*` 自动失效?
- 在 `isolate` 内的子元素,父级 `isolate` 已经隔离了外部影响,内部 `z-*` 是否就只是"安心咒"?
- DOM 顺序天然决定的 paint order(后者覆盖前者),还需要 `z-*` 吗?

不需要就删。"能用就留" 是错的。

## key / fallback 稳定性

- React `key` 用 `array.length - 1 - i` / `i` 这种位置 fallback,**永远不稳定** —— 上游 schema 是否保证 id 必填?是的话直接用 id,删掉 fallback
- `state || fallback` 的 fallback 分支是否真的可达,看类型

## 跨文件 / 跨 codebase 检查(grep 才能抓到)

这些是 LLM/lint/TS 看 diff 时容易漏的,必须主动 grep:

- **常量去重**:本次新引入的字面量(数字、邮箱后缀、interval 字符串、固定 URL 等),用 `grep` 看在 codebase 其他地方有没有相同字面值。如果有 ≥2 处,抽到共享模块 export(优先 schema / contracts / config 模块)
- **私有 vs 共享常量**:本次定义的业务规则常量(`*_LIMIT`、`*_DOMAIN`、`*_WINDOW_*`)是否 export 出来给跨 service 使用,还是被私有锁在某个 service 文件
- **状态字段的所有写入入口**:本次给某个状态变化加了副作用钩子(例如 webhook 触发时调 X),用 `grep` 找出所有更新该状态字段的代码路径(`UPDATE *table* SET *col*` / `.update(table).set({col:`),逐一确认是否需要镜像调 X。最常见的漏:webhook 加了,但 sync API / admin override 路径没加
- **相似 entry point 的防御一致**:本次给一个入口加了防御 guard(`email_verified`、`role` 检查、rate limit、permission check),搜索是否有相似入口缺这个 guard
- **design token 反向查找**:如果想用 primitive color(`text-white` / `#000` / `text-[#fff]`)或对 lint 规则 disable,先 grep design system 文件(`semantic*.css` / `theme*.css` / `tokens*`),看是否已有"在 light/dark 下都符合需求"的语义 token。`*-fg` / `*-contrast` 类后缀的 token 通常是候选

## 命名 / API 重新审视

- **函数名是否还匹配行为**:函数经历过 ≥2 次重大修改的(看 git log 或近期 diff),重新读名字 + 实现。`is*`、`get*`、`check*` 这些 read-only 暗示的命名,如果实现里有 INSERT/UPDATE/DELETE 就要改名(候选:`evaluate*`、`sync*`、`apply*`)
- **JSDoc 更新与名字背离**:如果修了 JSDoc 增加"actually writes to DB"这种说明,大概率是名字该改了的信号
- **导出对象 / 模块 API**:`export const X = { ... }` 列表里的方法名跟内部函数名同步过没

## 评判阈值

不要为了避免改动而给自己台阶下:
- ❌ "stylistic preference, dismiss" —— 重新评估,如果项目有惯例就跟惯例
- ❌ "borderline,留着" —— 选一边,用通用 simplify 标准做决定
- ❌ "需要视觉验证,不动" —— 改了再让人验证,不要因为怕验证就跳过
- ❌ "未来可能要扩展" —— 现在不用,就硬编码;真要扩展时再加 prop
- ❌ "改一下不优雅" —— 优雅不是借口,简单才是

## 修复后再跑一遍

如果本次 review 产生了修复,对修复后的代码**再跑一遍**同样的检查 —— 修复本身可能引入新的 DRY 或 cycle,也可能你刚加的代码就有自审盲区。
