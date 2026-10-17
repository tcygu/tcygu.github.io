# 本地预览：.\scripts\serve.ps1
# 会自动找到虚拟环境里的 mkdocs，并热重载

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# 兼容「装了 git 但终端 PATH 还没刷新」的情况
$gitDir = "C:\Program Files\Git\cmd"
if ((Test-Path $gitDir) -and ($env:PATH -notlike "*$gitDir*")) {
    $env:PATH = "$gitDir;$env:PATH"
}

$candidates = @(
    (Join-Path $root ".venv\Scripts\python.exe"),   # 标准 Windows Python
    (Join-Path $root ".venv\bin\python.exe")        # msys2 / MSYS 环境的 Python
)
$python = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $python) {
    Write-Host "找不到虚拟环境，先执行：" -ForegroundColor Yellow
    Write-Host "  python -m venv .venv" -ForegroundColor Yellow
    Write-Host "  pip install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

Write-Host "使用 $python" -ForegroundColor DarkGray
Write-Host "预览地址 http://127.0.0.1:8000" -ForegroundColor Green
& $python -m mkdocs serve @args
