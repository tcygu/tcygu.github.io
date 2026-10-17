# 我的小窝

个人博客源码。用 [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) 构建，
部署在 GitHub Pages。

> 📘 **日常更新请看 [MANUAL.md](MANUAL.md)**（完整操作手册：写文章、改文章、图片、发布、排错）。

## 第一次上手

```powershell
# 1. 建虚拟环境（只需一次）
python -m venv .venv
.\.venv\Scripts\Activate.ps1        # msys2 的 Python 则是 .\.venv\bin\Activate.ps1
pip install -r requirements.txt

# 2. 本地预览（改文件会热重载）
.\scripts\serve.ps1
# 打开 http://127.0.0.1:8000

# 3. 构建（产物在 site/）
.\scripts\build.ps1
```

## 站点配置（已填好，需要时再改）

| 位置 | 当前值 |
| --- | --- |
| `mkdocs.yml` → `site_url` | `https://tcygu.github.io/` |
| `mkdocs.yml` → `site_name` | `tcygu.github.io` |
| `mkdocs.yml` → `site_author` / `copyright` | `tcygu` |
| `mkdocs.yml` → `repo_name` / `repo_url` | `tcygu/tcygu.github.io` |
| `mkdocs.yml` → `extra.social` | GitHub 已填；邮箱待填（已注释，搜索 `TODO`） |
| `docs/index.md` | 首页自我介绍已填 `tcygu` |
| `docs/about.md` | GitHub 已填；邮箱 / Codeforces / 洛谷待填（`TODO` 注释块） |
| `docs/blog/.authors.yml` | 作者 `tcygu`，头像取 GitHub 头像 |

> 还没填的三项（邮箱、Codeforces、洛谷）都在注释里，填好后删掉注释符号即可。

## 目录结构

```text
my-blog/
├─ mkdocs.yml              # 全站配置（导航、插件、主题）
├─ requirements.txt        # 依赖，CI 也用这份
├─ docs/
│  ├─ index.md             # 首页
│  ├─ about.md  friends.md tags.md
│  ├─ blog/                # 随笔（自动生成列表 / 归档 / 分类 / RSS）
│  │  ├─ .authors.yml
│  │  └─ posts/2026-10-14-hello-blog.md
│  ├─ algo/                # 算法笔记：dp / ds / math / graph / string / misc
│  ├─ solution/2026/       # 题解，按年份
│  ├─ records/             # 刷题记录、集训总结
│  ├─ misc/                # 游记、日记
│  ├─ snippets/            # 可复用的代码块
│  ├─ javascripts/katex.js # KaTeX 配置与全局宏
│  └─ stylesheets/extra.css
├─ scripts/                # 本地 serve / build 脚本
└─ .github/workflows/deploy.yml   # push 到 main 就自动部署
```

## 写一篇新文章

**随笔**（会出现在博客列表、归档、RSS 里）

`docs/blog/posts/2026-10-15-slug.md`：

```markdown
---
date: 2026-10-15
authors: [me]
categories: [游记]
tags: [NOIP]
---

# 标题

摘要，会显示在列表里。

<!-- more -->

正文……
```

**题解 / 笔记**（进侧栏导航，被标签索引）

在 `docs/solution/2026/` 下新建 `CF2274E.md`：

```markdown
---
date: 2026-10-15
tags: [题解, 动态规划]
---

# CF2274E · 标题

思路……
```

然后在 `mkdocs.yml` 的 `nav` 里加一行：

```yaml
      - 2026 年:
          - solution/2026/index.md
          - CF2274E: solution/2026/CF2274E.md
```

## 常用写法

````markdown
行内公式 $O(n\log n)$，行间公式：

$$\sum_{i=1}^{n} a_i$$

```cpp title="sol.cpp" hl_lines="3"
int main() { return 0; }
```

!!! note "提示框"
    支持 note / tip / warning / danger 等。

=== "C++"
    ```cpp
    int x;
    ```

=== "Python"
    ```python
    x = 0
    ```
````

复用代码（`docs/snippets/cf-template.cpp`）：

```markdown
--8<-- "snippets/cf-template.cpp"
```

## 评论（giscus）

评论挂在 GitHub Discussions 上，免费、无服务器。代码已经接好，只差两个开关：

1. **仓库开启 Discussions**：Settings → General → Features → 勾选 **Discussions**
2. 打开 <https://giscus.app/zh-CN>，「仓库」填 `tcygu/tcygu.github.io`
3. 分类选 **Announcements**（或新建一个），按提示授权
4. 页面下方会生成一段配置，把其中的 **`data-category-id`** 复制到
   `mkdocs.yml` → `extra.giscus.category_id`（现在还是空的）
5. `.\scripts\publish.ps1 -Message "feat: 开启评论"` 发布

填好后，博客文章页和题解页底部就会出现评论区。

| 项 | 说明 |
| --- | --- |
| `repo` / `repo_id` | 已填好（`R_kgDOVNHZGg`），不用动 |
| 显示范围 | `blog/posts/` 和 `solution/` 下**非 index** 的页面 |
| 单独开启 | 页面 front matter 加 `comments: true` |
| 单独关闭 | 加 `comments: false` |
| 主题 | 跟随站点深浅色自动切换（`overrides/partials/comments.html` 里有同步脚本） |

## 图片（图床）

推荐直接把图片放进仓库，不依赖任何第三方图床：

```powershell
.\scripts\add-image.ps1 .\screenshot.png
.\scripts\add-image.ps1 a.jpg b.png -MaxWidth 1200 -Quality 80
```

脚本会：

- 超过 `MaxWidth`（默认 1600px）的等比缩小
- 不透明的图自动在 PNG / JPEG 里选体积小的那个（截图通常能省 50% 以上）
- 有透明通道的保持 PNG
- 压缩后反而变大就直接用原图
- 存进 `docs\assets\2026-10\`，并打印可直接粘贴的 Markdown

输出示例：

```text
[OK] shot.png
     尺寸 1600x1067   体积 471 KB -> 237 KB（省 50%）
     ![](/assets/2026-10/shot.jpg)
```

> 图片地址用 `/assets/...` 这种站点根路径，从任何目录的 md 文件都能正确引用。
> 以后图片多到仓库膨胀，再迁到 Cloudflare R2 / 阿里云 OSS，把 `/assets/` 前缀换成图床域名即可。

## 阅读数

页脚显示「本文阅读 N 次 · 全站访问 M 次 · 访客 U 人」，用的是[不蒜子](https://busuanzi.ibruce.info/)：

- 零配置、免费、国内可访问
- 脚本在 `mkdocs.yml` 的 `extra_javascript`，显示模板在 `overrides/partials/copyright.html`
- 服务挂掉时整块自动隐藏，不会留下「本文阅读 次」这种空文案
- ⚠️ **不要开启 `navigation.instant`**，否则页面不整页刷新，计数不会更新

想要更精确的统计（来源、停留时间），可以另接 Cloudflare Web Analytics 或 umami，把 `extra_javascript` 里 busuanzi 那行删掉即可。

## 部署

1. 在 GitHub 新建仓库 `你的用户名.github.io`，把本项目 push 上去（分支 `main`）。
2. 仓库 **Settings → Actions → General → Workflow permissions** 选
   **Read and write permissions**（`mkdocs gh-deploy` 需要推送 `gh-pages`）。
3. 仓库 **Settings → Pages** → Source 选 **Deploy from a branch** → 分支 `gh-pages` / `(root)`。
4. 之后每次 `git push`，Actions 会自动构建并更新线上站点。

> ⚠️ **如果你的电脑开着本地代理（Clash / v2ray / Surge 等）**
>
> 浏览器能上 GitHub 不代表 `git` 能上——git 不读 Windows 的“系统代理”设置。症状是：
> `Failed to connect to github.com:443`，但网页打得开。
>
> 让 git 也走代理（端口换成你自己客户端的）：
>
> ```powershell
> git config --global http.proxy http://127.0.0.1:12450
> git config --global https.proxy http://127.0.0.1:12450
> ```
>
> 彻底关掉代理后如果不通，清掉配置：
>
> ```powershell
> git config --global --unset http.proxy
> git config --global --unset https.proxy
> ```
>
> 本机当前已配置为 `127.0.0.1:12450`。

## 一条命令发布

`scripts/publish.ps1` 把「构建自检 → 拉取远程 → 提交 → 推送」合成一步：

```powershell
# 带提交信息
.\scripts\publish.ps1 -Message "post: 新增 CF2274E 题解"

# 不写信息，自动用当前时间
.\scripts\publish.ps1

# 有改动但不想跑构建自检
.\scripts\publish.ps1 -Message "fix: 改错别字" -SkipCheck
```

它按这个顺序执行，中间任何一步失败都会停下来：

1. `mkdocs build --strict`——内容有错就不提交（`-SkipCheck` 可跳过）
2. `git pull --rebase --autostash`——多设备写作时避免 push 被拒
3. `git add -A` + `git commit -F`（从 UTF-8 文件读提交信息，中文不会乱码）
4. `git push`
5. 打印本次提交和 Actions 部署链接

> 提交信息建议用前缀：`post:` 新文章、`fix:` 修正、`chore:` 杂务。

## 可选增强

- **统计**：Cloudflare Web Analytics / umami（比不蒜子精确）
- **图床**：Cloudflare R2 / 阿里云 OSS（图片量大时）
- **Mermaid 流程图**：`pymdownx.superfences` 的 `custom_fences` + `mermaid.esm.min.mjs`
- **Cloudflare Pages**：同一仓库再挂一份，国内访问更稳
- **搜索增强**：`search` 插件已内置，可加 `search.boost` 给常用页面加权
