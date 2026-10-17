# 我的小窝

个人博客源码。用 [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) 构建，
部署在 GitHub Pages。

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

## 部署

1. 在 GitHub 新建仓库 `你的用户名.github.io`，把本项目 push 上去（分支 `main`）。
2. 仓库 **Settings → Actions → General → Workflow permissions** 选
   **Read and write permissions**（`mkdocs gh-deploy` 需要推送 `gh-pages`）。
3. 仓库 **Settings → Pages** → Source 选 **Deploy from a branch** → 分支 `gh-pages` / `(root)`。
4. 之后每次 `git push`，Actions 会自动构建并更新线上站点。

## 可选增强

- **评论**：[giscus](https://giscus.app/)（挂在 GitHub Discussions 上，免费）
- **统计**：Cloudflare Web Analytics / umami
- **图床 / 大图**：图片放 `docs/assets/`，超过 1MB 的先压缩
- **Mermaid 流程图**：`pymdownx.superfences` 的 `custom_fences` + `mermaid.esm.min.mjs`
- **Cloudflare Pages**：同一仓库再挂一份，国内访问更稳
