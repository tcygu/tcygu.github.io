# 构建静态站点：.\scripts\build.ps1
# 产物在 site\ 目录

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

# 没有 git 时，RSS 插件的依赖 GitPython 会抛异常；先压掉。
$env:GIT_PYTHON_REFRESH = "quiet"

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
