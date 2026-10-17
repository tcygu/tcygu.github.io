# 构建静态站点：.\scripts\build.ps1
# 产物在 site\ 目录

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# 兼容「已经装了 git，但当前终端是装之前开的」——PATH 没刷新时 GitPython 会找不到 git
$gitDir = "C:\Program Files\Git\cmd"
if ((Test-Path $gitDir) -and ($env:PATH -notlike "*$gitDir*")) {
    $env:PATH = "$gitDir;$env:PATH"
}

$candidates = @(
    (Join-Path $root ".venv\Scripts\python.exe"),
    (Join-Path $root ".venv\bin\python.exe")
)
$python = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $python) {
    Write-Host "找不到虚拟环境，先执行 pip install -r requirements.txt" -ForegroundColor Yellow
    exit 1
}

& $python -m mkdocs build --strict @args
exit $LASTEXITCODE
