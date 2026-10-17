# 一条命令发布博客
#
#   .\scripts\publish.ps1 -Message "post: 新增题解"
#   .\scripts\publish.ps1                              # 自动生成提交信息
#   .\scripts\publish.ps1 -Message "fix: 错别字" -SkipCheck
#
# 流程：构建自检 -> 拉取远程 -> 提交 -> 推送

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Message = "",

    [switch]$SkipCheck
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

# 兼容「装了 git 但终端 PATH 还没刷新」的情况
$gitDir = "C:\Program Files\Git\cmd"
if ((Test-Path $gitDir) -and ($env:PATH -notlike "*$gitDir*")) {
    $env:PATH = "$gitDir;$env:PATH"
}

function Find-Exe {
    param([string[]]$Candidates)
    $Candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}

# ---------- 找 git ----------
$git = Find-Exe @(
    "C:\Program Files\Git\cmd\git.exe",
    "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe",
    (Get-Command git -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
)
if (-not $git) {
    Write-Host "[x] 找不到 git，先装：winget install --id Git.Git -e" -ForegroundColor Red
    exit 1
}

# ---------- 有没有改动 ----------
$changes = & $git status --porcelain
if (-not $changes) {
    Write-Host "[=] 没有改动，无需发布。" -ForegroundColor Yellow
    exit 0
}

Write-Host "[i] 待提交的改动：" -ForegroundColor DarkGray
$changes | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }

# ---------- 1. 构建自检 ----------
if (-not $SkipCheck) {
    $py = Find-Exe @(
        (Join-Path $root ".venv\Scripts\python.exe"),
        (Join-Path $root ".venv\bin\python.exe")
    )
    if ($py) {
        Write-Host "`n[1/4] 构建自检（mkdocs build --strict）..." -ForegroundColor Cyan
        & $py -m mkdocs build --strict --quiet
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[x] 构建失败，已取消发布。看上面的 WARNING / ERROR。" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "`n[!] 没找到虚拟环境，跳过构建自检。" -ForegroundColor Yellow
    }
}

# ---------- 提交信息 ----------
if (-not $Message) {
    $Message = "post: 更新于 $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

# ---------- 2. 同步远程 ----------
Write-Host "`n[2/4] 同步远程（git pull --rebase --autostash）..." -ForegroundColor Cyan
& $git pull --rebase --autostash --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "[x] 拉取失败：可能有冲突，或网络不通。" -ForegroundColor Red
    Write-Host "    解决冲突后执行 git rebase --continue，再重新发布。" -ForegroundColor DarkGray
    exit 1
}

# ---------- 3. 提交 ----------
Write-Host "`n[3/4] 提交：$Message" -ForegroundColor Cyan
& $git add -A

# 提交信息写进 UTF-8 文件再交给 git，避免中文编码问题
$msgFile = Join-Path $env:TEMP "publish-commit-msg.txt"
[System.IO.File]::WriteAllText($msgFile, $Message, [System.Text.UTF8Encoding]::new($false))
& $git commit --quiet --file $msgFile
$commitCode = $LASTEXITCODE
Remove-Item $msgFile -Force -ErrorAction SilentlyContinue
if ($commitCode -ne 0) {
    Write-Host "[x] 提交失败。" -ForegroundColor Red
    exit 1
}

# ---------- 4. 推送 ----------
Write-Host "`n[4/4] 推送..." -ForegroundColor Cyan
& $git push --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "[x] 推送失败：检查网络或 GitHub 凭据。" -ForegroundColor Red
    exit 1
}

# ---------- 完成 ----------
$last = & $git log -1 --pretty="%h %s"

# 从 remote 推导 Actions 链接
$actionsUrl = "https://github.com/tcygu/tcygu.github.io/actions"
$remote = & $git remote get-url origin 2>$null
if ($remote -match 'github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$') {
    $actionsUrl = "https://github.com/$($Matches[1])/$($Matches[2])/actions"
}

Write-Host ""
Write-Host "[OK] 已发布：$last" -ForegroundColor Green
Write-Host "     部署进度：$actionsUrl" -ForegroundColor DarkGray
Write-Host "     线上地址：https://tcygu.github.io/   （等 30-60 秒）" -ForegroundColor DarkGray
