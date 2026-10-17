# 博客操作手册

> **站点**：<https://tcygu.github.io/>
> **本地目录**：`C:\Users\27349\Desktop\my-blog`
> **仓库**：<https://github.com/tcygu/tcygu.github.io>
> **技术栈**：MkDocs Material 9.7 · GitHub Pages
> **最后更新**：2026-10-17

这份手册覆盖：写文章、改文章、发图片、发布、排错、换电脑。
遇到问题先看 [第 13 节 故障排查](#13-故障排查)。

> 本文件放在仓库根目录，**不会发布到网站上**（只有 `docs/` 里的内容才会）。

---

## 0. 30 秒速查

```powershell
cd $env:USERPROFILE\Desktop\my-blog

.\scripts\serve.ps1                            # 本地预览 http://127.0.0.1:8000
.\scripts\publish.ps1 -Message "post: 标题"     # 一键发布
.\scripts\build.ps1                            # 只检查，不发布
.\scripts\add-image.ps1 .\图片.png              # 图片压缩入库
```

日常只有三件事：**开预览 → 写 md → publish**。

---

## 1. 站点地图：哪个 URL 对应哪个文件

| URL | 文件 | 谁生成 |
|---|---|---|
| `/` | `docs/index.md` | 手写 |
| `/blog/` | `docs/blog/index.md` | 手写（列表自动注入） |
| `/blog/2026/10/14/新博客建立啦/` | `docs/blog/posts/2026-10-14-hello-blog.md` | 手写 |
| `/blog/archive/2026/` | — | **自动**（按 `date` 分年） |
| `/blog/category/杂谈/` | — | **自动**（按 `categories`） |
| `/algo/` | `docs/algo/index.md` | 手写 |
| `/algo/dp/` | `docs/algo/dp/index.md` | 手写 |
| `/solution/` | `docs/solution/index.md` | 手写 |
| `/solution/2026/stonebag-C/` | `docs/solution/2026/stonebag-C.md` | 手写 |
| `/records/` | `docs/records/index.md` | 手写 |
| `/misc/` | `docs/misc/index.md` | 手写 |
| `/tags/` | `docs/tags.md` | 手写（标签自动注入） |
| `/about/` | `docs/about.md` | 手写 |
| `/friends/` | `docs/friends.md` | 手写 |
| `/feed_rss_created.xml` | — | **自动** |
| `/sitemap.xml` | — | **自动** |
| `/404.html` | — | **自动** |

**两条 URL 生成的铁律**（发布后改了就救不回来）：

1. **随笔**的 URL = `/blog/{date 的年/月/日}/{H1 标题 slug}/`
   —— 也就是**改了正文第一行的 `# 标题`，URL 就变了**。
2. **题解 / 笔记**的 URL = 文件路径（`docs/solution/2026/CF2274E.md` → `/solution/2026/CF2274E/`）
   —— 也就是**改了文件名，URL 就变了**。

---

## 2. 环境自检

### 2.1 目录和 Python

```powershell
cd $env:USERPROFILE\Desktop\my-blog
.\.venv\bin\python.exe -m mkdocs --version
```

期望输出：`python -m mkdocs, version 1.6.1 ...`

> 你这台机器用的是 MSYS2 的 Python 3.14，虚拟环境目录是 `.venv\bin\`（不是常见的 `.venv\Scripts\`）。
> 下面的几个脚本都已自动适配，**你不需要手动激活虚拟环境**。
> 终端里直接敲 `python` 会弹微软商店，这是正常的——别去装它，用脚本就行。

### 2.2 三个脚本

| 脚本 | 作用 |
|---|---|
| `scripts\serve.ps1` | 本地预览，改动自动热重载 |
| `scripts\build.ps1` | `mkdocs build --strict`，有警告就失败 |
| `scripts\publish.ps1` | 自检 → 拉取 → 提交 → 推送 |
| `scripts\add-image.ps1` | 图片压缩 + 入库 + 生成 Markdown |
### 2.3 网络与代理（重要）

你的电脑开着本地代理 `127.0.0.1:12450`。**git 不读 Windows 系统代理**，所以已经单独给 git 配了：

```powershell
git config --global --get http.proxy     # 应输出 http://127.0.0.1:12450
```

| 情况 | 处理 |
|---|---|
| 换了代理端口 | 重新设置 `http.proxy` / `https.proxy`（见 13.6） |
| 彻底不用代理 | `git config --global --unset http.proxy`（https 同理） |
| 代理没开 | `publish.ps1` 会自动检测端口不通并改直连 |

---

## 3. 四种内容类型：写哪个？

| 类型 | 放哪里 | 要改 `nav` 吗 | 进 RSS | 自动开评论 |
|---|---|---|---|---|
| **随笔** | `docs/blog/posts/` | ❌ 不用 | ✅ | ✅ |
| **题解** | `docs/solution/{年份}/` | ✅ 必须 | ❌ | ✅ |
| **算法笔记** | `docs/algo/{分类}/` | ✅ 必须 | ❌ | ❌ |
| **记录** | `docs/records/` | ✅ 必须 | ❌ | ❌ |

记法：**随笔自动，笔记手动**。

---

## 4. 发一篇随笔（完整流程）

### 4.1 模板（直接复制）

文件：`docs/blog/posts/2026-10-20-csp-2026.md`

```markdown
---
date: 2026-10-20
authors:
  - me
categories:
  - 游记
tags:
  - CSP
  - 竞赛
---

# CSP 2026 游记

十月，又到了每年最紧张的那个周末。

<!-- more -->

## Day 0：出发

正文……
```

### 4.2 Front Matter 字段

| 字段 | 必填 | 作用 | 不写的后果 |
|---|---|---|---|
| `date` | ✅ | 排序、归档、URL、RSS 时间 | 构建报错 |
| `authors` | ❌ | 署名，值必须是 `.authors.yml` 里的 key（现在只有 `me`） | 报 `Couldn't find author 'xxx'` |
| `categories` | ❌ | 生成 `/blog/category/xxx/` | 只是没有分类页 |
| `tags` | ❌ | 进 `/tags/` 与 RSS 的 category | 只是没有标签 |
| `<!-- more -->` | 强烈建议 | 之前的内容 = 列表卡片摘要 | 列表里显示全文 |
| `slug` | ❌ | 固定 URL（改了标题 URL 也不变） | URL 跟着标题变 |
| `pin: true` | ❌ | 置顶到博客列表最前 | 按日期排序 |
| `draft: true` | ❌ | 本地能看，**发布时会被排除** | 正常发布 |
| `comments: false` | ❌ | 这一页关闭评论 | 默认开启 |

**关于草稿**：写一半想收工，加 `draft: true`。`serve.ps1` 里能看到，`publish.ps1` 构建时会自动跳过，不会上线。写完删掉这一行即可。

### 4.3 操作步骤

```powershell
# ① 开预览（窗口 A，一直开着）
cd $env:USERPROFILE\Desktop\my-blog
.\scripts\serve.ps1
# 浏览器打开 http://127.0.0.1:8000

# ② 新建文件（VS Code）
code docs\blog\posts\2026-10-20-csp-2026.md

# ③ 粘贴 4.1 的模板，写内容。保存 = 浏览器自动刷新

# ④ 发布（窗口 B，另开一个终端）
cd $env:USERPROFILE\Desktop\my-blog
.\scripts\publish.ps1 -Message "post: CSP 2026 游记"
```

期望输出：

```text
[i] 待提交的改动：
    ?? docs/blog/posts/2026-10-20-csp-2026.md

[1/4] 构建自检（mkdocs build --strict）...
[2/4] 同步远程（git pull --rebase --autostash）...
[3/4] 提交：post: CSP 2026 游记
[4/4] 推送...

[OK] 已发布：a1b2c3d post: CSP 2026 游记
```

### 4.4 验收

等 30–60 秒：

1. <https://github.com/tcygu/tcygu.github.io/actions> → 最新 `deploy` 绿色对勾
2. 无痕窗口打开 <https://tcygu.github.io/blog/> → 文章在第一条
3. 点进去检查：公式、代码、图片、底部评论框、页脚阅读数
4. <https://tcygu.github.io/feed_rss_created.xml> → 新文章在里面

---

## 5. 发一篇题解

和随笔的差异：**多改两个文件**。

### 5.1 正文

`docs/solution/2026/CF2274E.md`

````markdown
---
date: 2026-10-20
tags:
  - 题解
  - 动态规划
---

# CF2274E · 题目名

## 题意

给定长度为 $n$ 的序列……

## 思路

设 $f_i$ 表示前 $i$ 个位置的最优值：

$$f_i=\min_{j<i}\{f_j+w(j,i)\}$$

## 代码

```cpp title="sol.cpp"
int main() { return 0; }
```
````

### 5.2 年份索引页

`docs/solution/2026/index.md`

```markdown
# 2026 年题解

- [石子袋子 C · 坏状态计数的完整推导](stonebag-C.md)
- [CF2274E · 题目名](CF2274E.md)          <!-- 新增 -->
```

### 5.3 导航登记

`mkdocs.yml` 的 `nav`：

```yaml
  - 题解:
      - solution/index.md
      - 2026 年:
          - solution/2026/index.md
          - 石子袋子 C: solution/2026/stonebag-C.md
          - CF2274E: solution/2026/CF2274E.md    # ← 新增
```

> 忘了第 5.3 步：页面照样能生成、链接能打开，但**左侧导航里找不到它**，而且 `--strict` 构建会报 `not included in the nav` 警告。

### 5.4 发布

```powershell
.\scripts\publish.ps1 -Message "post: CF2274E 题解"
```

---

## 6. 发一篇算法笔记

流程和题解完全一样，只是目录不同：

1. 正文：`docs/algo/{dp|ds|math|graph|string|misc}/xxx.md`
2. 分类索引：在对应 `index.md` 里加链接（可选，但读者会看）
3. `nav` 登记：

```yaml
  - 算法笔记:
      - algo/index.md
      - 动态规划: algo/dp/index.md
      # 想加二级页面：
      # - 动态规划:
      #     - algo/dp/index.md
      #     - 高维前缀和: algo/dp/sos-dp.md
```

> 注意：`nav` 里同一个父节点要么写「一个文件」，要么写「一组子项」，不能混。加了子项后，原本的 `动态规划: algo/dp/index.md` 要变成列表的第一项 `algo/dp/index.md`（不带标题）。

---

## 7. 修改文章

**原则：`docs/` 里的 md 是唯一真相，所有修改都是「改文件 → 发布」。**

```powershell
# 窗口 A
.\scripts\serve.ps1

# 改文件、保存、浏览器自动刷新

# 窗口 B
.\scripts\publish.ps1 -Message "fix: 修正 XXX"
```

### 7.1 六种场景

| 场景 | 要做什么 | 副作用 |
|---|---|---|
| 改错别字 / 补内容 | 直接改 | 无 |
| **改 `# 标题`（随笔）** | 直接改 | ⚠️ **URL 变了**，旧链接 404，评论变空 |
| 改 `date` | 直接改 | ⚠️ URL 变、排序变、归档页可能换年 |
| 改 `tags` / `categories` | 直接改 | 自动重算，不用手删旧页面 |
| 改文件名（题解/笔记） | 改名 + 改 `nav` + 改索引链接 | ⚠️ URL 变 |
| 换封面/图片 | 改图片路径 | 无 |

### 7.2 想让 URL 永不改变

在 front matter 里固定 slug：

```yaml
---
date: 2026-10-20
slug: csp-2026      # URL 固定为 /blog/2026/10/20/csp-2026/
---
```

> 已经发布的文章才加 `slug`，那一次 URL 本身会变（从中文标题变成 slug）。想稳妥，**发布前**就写好。

### 7.3 修改后没生效？

1. 本地：`serve.ps1` 是不是还开着？改的是不是 `docs/` 里的文件（不是 `site/`）？
2. 线上：等 Actions 跑完；浏览器用无痕或 `Ctrl + F5`。
3. 检查是否忘了推送：`git status` 应该干净；`publish.ps1` 最后一行会给出 commit 号。

---

## 8. 删除文章

```powershell
# ① 删文件
Remove-Item docs\blog\posts\2026-10-20-csp-2026.md

# ② 题解/笔记还要清理两处
#    - mkdocs.yml 的 nav 里那一行
#    - docs/solution/2026/index.md 里那条链接

# ③ 发布
.\scripts\publish.ps1 -Message "chore: 删除 CSP 游记"
```

> 只是删网页。giscus 里对应的 Discussion 还在 GitHub → Discussions，需要的话手动删。
> RSS 里也会随之消失（下次构建重算）。

---

## 9. 图片

### 9.1 用脚本（推荐）

```powershell
.\scripts\add-image.ps1 .\screenshot.png
.\scripts\add-image.ps1 a.jpg b.png
.\scripts\add-image.ps1 .\huge.jpg -MaxWidth 1200 -Quality 80
```

输出：

```text
[OK] screenshot.png
     尺寸 1600x1067   体积 471 KB -> 237 KB（省 50%）
     文件 docs\assets\2026-10\screenshot.jpg
     粘到文章里：
     ![](/assets/2026-10/screenshot.jpg)
```

把最后一行粘进文章即可。

**压缩规则**：

1. 超过 `MaxWidth`（默认 1600）等比缩小
2. 有透明通道 → 存 PNG
3. 不透明 → PNG / JPEG 各编一份，取体积小的
4. 压完反而更大 → 直接用原图

**限制**：只支持 PNG / JPG / GIF / BMP；**不支持 WebP / AVIF**（先另存为 PNG/JPG）。GIF 只保留第一帧（会丢动画）。

### 9.2 手工放图

放到 `docs/assets/2026-10/任何名字.png`，引用：

```markdown
![](/assets/2026-10/任何名字.png)
```

**用 `/assets/...` 根路径**，从任何目录的 md 都能正确引用。

### 9.3 图床

现在图片跟着仓库走：版本化、无第三方依赖、不会挂。图片多了想迁到 Cloudflare R2 / 阿里云 OSS 时，只要把 `/assets/` 前缀换成图床域名即可，脚本里的路径不用改。

---

## 10. 写作语法速查

### 数学（KaTeX）

```markdown
行内：$O(n\log n)$，$n\le 2\times10^5$

行间：
$$
\sum_{i=1}^{n} a_i=\binom{n}{2}
$$

自定义宏：$\R$ $\N$ $\Z$ $\Q$ $\C$ $\eps$ $\xor$ $\bigO(n^2)$ $\st$
```

宏定义在 `docs/javascripts/katex.js`，要加新宏改那里。

### 代码

````markdown
```cpp title="sol.cpp" hl_lines="2 4"
int main() {
    int n; cin >> n;
}
```
````

- `title` 显示文件名，`hl_lines` 高亮行
- 复制按钮自动出现

### 提示框

```markdown
!!! note "标题可选"
    缩进 4 个空格。

!!! warning
    警告内容。
```

可用：`note` `abstract` `info` `tip` `success` `question` `warning` `failure` `danger` `bug` `example` `quote`

### 折叠

```markdown
??? tip "点开看"
    默认收起。

???+ tip "默认展开"
    带 + 号。
```

### 标签页

````markdown
=== "C++"
    ```cpp
    int x;
    ```

=== "Python"
    ```python
    x = 0
    ```
````

### 代码模板复用

`docs/snippets/cf-template.cpp` 存一份，所有文章共享：

````markdown
```cpp
--8<-- "snippets/cf-template.cpp"
```
````

### 清单

```markdown
- [x] 已完成
- [ ] 未完成
```

### 表格 / 脚注 / 缩写

```markdown
| 列 1 | 列 2 |
| --- | --- |
| a | b |

有脚注[^1]。

[^1]: 脚注内容。

*[OI]: Olympiad in Informatics
```

### 图标

```markdown
:material-rocket: :fontawesome/brands/github: :material-alert:
```

### 链接

```markdown
[站内相对链接](../algo/dp/index.md)
[站点根路径](/solution/2026/CF2274E/)
[外链](https://codeforces.com)
```

---

## 11. 评论 / 阅读数 / RSS

### 评论（giscus）

- 自动出现在：`blog/posts/` 和 `solution/` 下**非 index** 的页面
- 单独开：front matter `comments: true`
- 单独关：`comments: false`
- 读者需要 GitHub 账号登录
- 第一条评论时，giscus bot 会自动在仓库 Discussions 里创建对应讨论
- 管理 / 删除：<https://github.com/tcygu/tcygu.github.io/discussions>
- 配置在 `mkdocs.yml` → `extra.giscus`（`repo_id`、`category_id` 已填好）

> ⚠️ 评论按 **URL 路径** 绑定。改了标题或日期导致 URL 变化，旧评论不会跟过来。

### 阅读数（不蒜子）

- 页脚显示：本文阅读 / 全站访问 / 访客数
- 数据在第三方（busuanzi）那边，服务挂了整块自动隐藏
- ⚠️ 不要开启 `navigation.instant`（无刷新跳页），否则计数不更新

### RSS

- 地址：`https://tcygu.github.io/feed_rss_created.xml`
- 只包含 `blog/posts/` 的文章（题解、笔记不进 RSS）
- 想让题解也进 RSS：把 `mkdocs.yml` 里 `match_path: "blog/posts/.*"` 改成 `.*`
- 浏览器打开会显示排版好的列表（依赖同目录的 `rss.xsl`）

---

## 12. 发布原理

```text
你 git push
  └→ GitHub Actions（ubuntu-latest）
       └→ pip install -r requirements.txt
            └→ mkdocs build
                 └→ mkdocs gh-deploy --force
                      └→ 推送到 gh-pages 分支
                           └→ GitHub Pages 发布（30-60 秒）
```

关键点：

- **`docs/` 是源码，`site/` 是产物**。`site/` 已被 `.gitignore` 忽略，永远不会提交。
- 每次发布都是**整站重建**，不存在"只传一页"的问题。
- 本地不需要手动上传任何文件。
- 提交记录在 `main` 分支，网站文件在 `gh-pages` 分支（不要直接改它）。

### `publish.ps1` 的三种行为

| 情况 | 行为 |
|---|---|
| 有新改动 | 构建自检 → 拉取 → 提交 → 推送 |
| 无改动，但有未推送提交 | 跳过自检和提交，只拉取 + 推送 |
| 都没有 | `[=] 没有改动，也没有未推送的提交，无需发布。` |

参数：

```powershell
.\scripts\publish.ps1 -Message "post: 标题"   # 指定提交信息
.\scripts\publish.ps1                        # 自动用时间做信息
.\scripts\publish.ps1 -Message "fix: xx" -SkipCheck   # 跳过构建自检
```

提交信息前缀建议：`post:` 新文章 / `fix:` 修正 / `docs:` 文档 / `chore:` 杂务 / `feat:` 新功能。

---

## 13. 故障排查

### 13.1 构建类

| 报错 | 原因 | 处理 |
|---|---|---|
| `Couldn't find author 'me'` | `authors` 写了 `.authors.yml` 里不存在的 key | 用 `me` 或去 `.authors.yml` 加一个 |
| `Aborted with a BuildError` | 内容有错 | 看报错的文件和行号 |
| `contains a link to 'xxx' which is not found` | 链接写错 | 站内链接写 `.md` 路径，不是 `.html` |
| `exists in the docs directory, but is not included in the nav` | 笔记忘了登记 | 加到 `mkdocs.yml` 的 `nav` |
| `Missing 'created' date` | 随笔没写 `date` | 补 `date: YYYY-MM-DD` |
| 中文乱码 | 文件存成了 GBK | VS Code 右下角 → Save with Encoding → UTF-8 |

### 13.2 网页表现类

| 现象 | 原因 | 处理 |
|---|---|---|
| 公式显示成 `$$...$$` 源码 | KaTeX CDN 没加载 | F12 → Network 看 katex 是否 200；可把 `cdn.jsdelivr.net` 换成 `fastly.jsdelivr.net` |
| 图片裂开 | 路径不是 `/assets/...` | 用 `add-image.ps1` 输出的那行 |
| 列表里显示全文 | 没写 `<!-- more -->` | 补上 |
| 评论区空白 | `category_id` 失效 / 分类名不匹配 | 重新从 giscus.app 取 |
| 评论变成空的 | 改了标题或日期，URL 变了 | 去 Discussions 把旧讨论改到新路径 |
| 阅读数不涨 | 开了 `navigation.instant` | 关掉该 feature |
| 404 页面不生效 | 正常现象（GitHub Pages 需要时间） | 等 1 分钟 |

### 13.3 发布类

| 现象 | 原因 | 处理 |
|---|---|---|
| Actions 红叉 `Permission denied` | 没有写权限 | Settings → Actions → 读写权限 |
| `rejected` / `non-fast-forward` | 远程有新提交 | `publish.ps1` 已自动 rebase；冲突需手动 |
| 页面 404 | Pages 分支没选 `gh-pages` | Settings → Pages 检查 |
| 发布成功但页面没变 | 缓存 | 无痕 / `Ctrl + F5` |

### 13.4 网络 / 代理

| 现象 | 原因 | 处理 |
|---|---|---|
| `Failed to connect to github.com:443` | git 没走代理 | 见下方配置 |
| `schannel: failed to receive handshake` | `NO_PROXY` 干扰本地代理 | `publish.ps1` 已自动处理 |
| `Failed to connect to 127.0.0.1:12450` | 代理客户端没开 | 开代理，或 `unset http.proxy` 走直连 |

```powershell
# 设置 / 更换代理端口
git config --global http.proxy  http://127.0.0.1:12450
git config --global https.proxy http://127.0.0.1:12450

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

---

## 14. 换电脑 / 备份 / 回滚

### 14.1 新电脑恢复

```powershell
git clone https://github.com/tcygu/tcygu.github.io.git
cd tcygu.github.io
python -m venv .venv
.\.venv\Scripts\Activate.ps1          # 标准 Python 是 Scripts；MSYS2 是 bin
pip install -r requirements.txt
.\scripts\serve.ps1
```

> **不要复制 `.venv` 文件夹**，跨机器不通用，必须重建。
> 新电脑第一次 push 需要重新登录 GitHub（浏览器授权或 PAT）。

### 14.2 备份

代码和文字全在 GitHub 上，已经天然备份。另外建议定期：

```powershell
git clone https://github.com/tcygu/tcygu.github.io.git D:\backup\blog-$(Get-Date -Format yyyyMMdd)
```

### 14.3 回滚

**还没发布**（只是改了文件）：

```powershell
git restore docs\blog\posts\xxx.md
```

**已经发布**：

```powershell
git log --oneline -10        # 找到那次提交
git revert <commit>
.\scripts\publish.ps1 -Message "revert: 撤销 XXX"
```

---

## 15. 附录

### 15.1 仓库结构

```text
my-blog/
├─ mkdocs.yml                 # 全站配置（导航/插件/主题/评论）
├─ requirements.txt           # 依赖（CI 也用这份）
├─ README.md                  # 快速上手
├─ MANUAL.md                  # 本手册
├─ .gitignore  .gitattributes
├─ scripts/
│  ├─ serve.ps1  build.ps1  publish.ps1  add-image.ps1
├─ overrides/partials/        # 主题覆盖
│  ├─ comments.html           # giscus 评论
│  └─ copyright.html          # 页脚 + 阅读数
├─ .github/workflows/deploy.yml
└─ docs/                      # ★ 只改这里
   ├─ index.md  about.md  friends.md  tags.md
   ├─ blog/{index.md,.authors.yml,posts/}
   ├─ algo/{index.md,dp,ds,math,graph,string,misc}
   ├─ solution/{index.md,2026/}
   ├─ records/index.md  misc/index.md
   ├─ assets/                 # 图片
   ├─ snippets/               # 可复用代码
   ├─ javascripts/katex.js
   └─ stylesheets/extra.css
```

### 15.2 常用命令

```powershell
cd $env:USERPROFILE\Desktop\my-blog

.\scripts\serve.ps1                                   # 预览
.\scripts\serve.ps1 -a 127.0.0.1:8001                 # 换端口
.\scripts\build.ps1                                   # 构建检查
.\scripts\publish.ps1 -Message "post: 标题"            # 发布
.\scripts\add-image.ps1 .\a.png -MaxWidth 1200        # 图片

git status                                            # 改了什么
git log --oneline -10                                 # 历史
git restore <file>                                    # 撤销未提交
git revert <sha>                                      # 撤销已发布
```

### 15.3 每次发布前的 30 秒检查

- [ ] 本地预览里排版正常（公式、代码、图片）
- [ ] `<!-- more -->` 写了
- [ ] 题解/笔记已在 `nav` 登记
- [ ] `build.ps1` 无警告
- [ ] 提交信息说清了这次改了什么
