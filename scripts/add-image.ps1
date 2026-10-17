# 把图片加进博客：自动压缩 + 改名 + 生成 Markdown 片段
#
#   .\scripts\add-image.ps1 .\screenshot.png
#   .\scripts\add-image.ps1 a.jpg b.png
#   .\scripts\add-image.ps1 .\huge.jpg -MaxWidth 1200 -Quality 80
#
# 输出到 docs\assets\YYYY-MM\，图片地址用站点根路径 /assets/...（任何页面都能引用）
# 依赖 Windows 自带的 System.Drawing，不需要额外安装任何东西
#
# 压缩策略：
#   1. 超过 MaxWidth 的先等比缩小
#   2. 有透明通道 -> 存 PNG
#   3. 不透明 -> PNG 和 JPEG 各编一份，取体积小的那个
#   4. 压缩后反而比原图大 -> 直接用原图（不为了缩尺寸而牺牲体积）

[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Path,

    [int]$MaxWidth = 1600,
    [int]$Quality = 85
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Add-Type -AssemblyName System.Drawing

$month = Get-Date -Format "yyyy-MM"
$destDir = Join-Path $root ("docs\assets\" + $month)
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

function ConvertTo-SafeName {
    param([string]$FilePath)
    $base = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $clean = ($base -replace '[^A-Za-z0-9._-]+', '-').Trim('-')
    if ([string]::IsNullOrWhiteSpace($clean)) {
        $clean = "img-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }
    return $clean
}

# 在缩略图上扫 alpha 通道，判断是否真的有透明像素
function Test-HasTransparency {
    param([System.Drawing.Bitmap]$Bitmap)

    if (-not [System.Drawing.Image]::IsAlphaPixelFormat($Bitmap.PixelFormat)) {
        return $false
    }

    $size = 128
    $probe = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($probe)
    $g.DrawImage($Bitmap, 0, 0, $size, $size)
    $g.Dispose()

    $rect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
    $data = $probe.LockBits($rect,
        [System.Drawing.Imaging.ImageLockMode]::ReadOnly,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bytes = New-Object byte[] ($data.Stride * $size)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
    $probe.UnlockBits($data)
    $probe.Dispose()

    for ($i = 3; $i -lt $bytes.Length; $i += 4) {
        if ($bytes[$i] -lt 250) { return $true }
    }
    return $false
}

function Save-Jpeg {
    param([System.Drawing.Bitmap]$Bitmap, [string]$Target, [int]$Q)

    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
        Where-Object { $_.MimeType -eq "image/jpeg" } |
        Select-Object -First 1
    $eps = New-Object System.Drawing.Imaging.EncoderParameters 1
    $eps.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
        [System.Drawing.Imaging.Encoder]::Quality, [long]$Q)
    $Bitmap.Save($Target, $codec, $eps)
    $eps.Dispose()
}

foreach ($p in $Path) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Host "[x] 找不到文件：$p" -ForegroundColor Red
        continue
    }

    $srcPath = (Resolve-Path -LiteralPath $p).Path
    $before = (Get-Item -LiteralPath $srcPath).Length
    $ext = [System.IO.Path]::GetExtension($srcPath).ToLower()

    try {
        $img = [System.Drawing.Image]::FromFile($srcPath)
    } catch {
        Write-Host "[x] 不是可识别的图片（WebP/AVIF 请先另存为 PNG 或 JPG）：$p" -ForegroundColor Red
        continue
    }

    $ratio = [Math]::Min(1.0, $MaxWidth / [double]$img.Width)
    $w = [Math]::Max(1, [int][Math]::Round($img.Width * $ratio))
    $h = [Math]::Max(1, [int][Math]::Round($img.Height * $ratio))

    $bmp = New-Object System.Drawing.Bitmap $w, $h
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($img, 0, 0, $w, $h)
    $g.Dispose()
    $img.Dispose()

    $hasAlpha = Test-HasTransparency -Bitmap $bmp

    # 两种格式各编一份，留小的
    $tmpBase = Join-Path $env:TEMP ("addimg-" + [Guid]::NewGuid().ToString("N"))
    $tmpPng = "$tmpBase.png"
    $candidates = @()

    $bmp.Save($tmpPng, [System.Drawing.Imaging.ImageFormat]::Png)
    $candidates += [pscustomobject]@{ Path = $tmpPng; Ext = ".png" }

    if (-not $hasAlpha) {
        $tmpJpg = "$tmpBase.jpg"
        Save-Jpeg -Bitmap $bmp -Target $tmpJpg -Q $Quality
        $candidates += [pscustomobject]@{ Path = $tmpJpg; Ext = ".jpg" }
    }

    $best = $candidates | Sort-Object { (Get-Item -LiteralPath $_.Path).Length } | Select-Object -First 1
    $bestSize = (Get-Item -LiteralPath $best.Path).Length
    $bmp.Dispose()

    $baseName = ConvertTo-SafeName $srcPath
    $useOriginal = ($bestSize -ge $before)

    if ($useOriginal) {
        # 压完更大，直接搬原图
        $outExt = $ext
        if ($outExt -notin @(".png", ".jpg", ".jpeg", ".gif")) { $outExt = ".png" }
        $outPath = Join-Path $destDir ($baseName + $outExt)
        $n = 1
        while (Test-Path -LiteralPath $outPath) {
            $outPath = Join-Path $destDir ("{0}-{1}{2}" -f $baseName, $n, $outExt)
            $n++
        }
        Copy-Item -LiteralPath $srcPath -Destination $outPath
    } else {
        $outPath = Join-Path $destDir ($baseName + $best.Ext)
        $n = 1
        while (Test-Path -LiteralPath $outPath) {
            $outPath = Join-Path $destDir ("{0}-{1}{2}" -f $baseName, $n, $best.Ext)
            $n++
        }
        Move-Item -LiteralPath $best.Path -Destination $outPath
    }

    Get-ChildItem -Path "$tmpBase*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

    $after = (Get-Item -LiteralPath $outPath).Length
    $saved = if ($before -gt 0) { 100 * (1 - $after / $before) } else { 0 }
    $url = "/assets/$month/" + (Split-Path $outPath -Leaf)

    Write-Host ""
    Write-Host ("[OK] " + (Split-Path $srcPath -Leaf)) -ForegroundColor Green
    Write-Host ("     尺寸 {0}x{1}   体积 {2:N0} KB -> {3:N0} KB（省 {4:N0}%）" -f `
            $w, $h, ($before / 1KB), ($after / 1KB), $saved) -ForegroundColor DarkGray
    if ($hasAlpha) { Write-Host "     检测到透明通道，保留 PNG" -ForegroundColor DarkGray }
    if ($useOriginal) { Write-Host "     压缩后反而更大，已保留原图" -ForegroundColor Yellow }
    if ($ext -eq ".gif") { Write-Host "     注意：GIF 只保留第一帧（动图会丢动画）" -ForegroundColor Yellow }
    Write-Host ("     文件 docs\assets\{0}\{1}" -f $month, (Split-Path $outPath -Leaf)) -ForegroundColor DarkGray
    Write-Host "     粘到文章里：" -ForegroundColor DarkGray
    Write-Host ("     ![]({0})" -f $url) -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[i] 文章里用 /assets/... 这种站点根路径，从任何目录的 md 文件都能正确引用。" -ForegroundColor DarkGray
