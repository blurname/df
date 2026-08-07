# Global Instructions

## Git Commits

- Do NOT add Claude as a co-author in commit messages. No `Co-Authored-By: Claude ...` lines.

## moon-hub（项目/数据统一管理）

`~/prj/moon-hub` 是我所有项目的管理枢纽（零依赖 python3 CLI），原则是"统一管理，不合并存储"。新建或改造项目时遵守：

- **仓库只放代码，数据归 Cloudflare**：任何项目的 `data/` 都要 gitignore，不准提交进 git。D1 存可查询的结构化部分，R2 存全量/大文件。判据是"D1 那份是否无损"——如果 D1 是有损投影（截断、丢字段），异地备份必须另外推 R2，只推 D1 等于没有完整备份
- **新项目要用 Cloudflare D1/R2 存数据时**：各项目建自己的库/桶（不共用），然后在 `~/prj/moon-hub/datasets.py` 里登记一个数据集条目（本地路径、D1 库名/R2 桶名、同步命令、已知问题）
- **不要为了少一个依赖牺牲易用性**：该用 Playwright / 该装库就装，目标是"一条命令能跑完"，不是依赖数量最少。不要把"这个项目目前恰好零依赖"当成必须维持的约束
- **同步入口统一**：`./moonhub sync <数据集>`，不要另起炉灶写独立的"记住要同步"逻辑；数据集自己的同步脚本放各自项目里，moon-hub 只调度
- **盘点**：`./moonhub status` 看数据（本地体积/D1 表行数/R2 对象数，声明但不存在的资源会标警告）；`./moonhub repos --problems` 看仓库健康（未提交/未推/无上游）
- 项目的已知存储问题记在 `datasets.py` 对应条目的 `issues` 列表里，修完删掉，不要只记在对话里
