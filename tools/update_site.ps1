# 发版时同步网站目录（site/）
#
# 用途：打完 APK 后，把新包放进 site/、改掉首页里的版本号和下载链接、
# 在更新日志顶部插一行占位，最后重新打包 dist\zhiji-site.zip。
#
# 为什么要自动做：这三处（文件名、版本文字、更新日志）每次发版都要改，
# 手改漏一处就会让网站挂着一个 404 的下载链接。
#
# 用法（一般由 build_apk.cmd 调用）：
#   pwsh -NoProfile -File tools\update_site.ps1 -ApkPath "dist\zhiji_oil_arm64_v1.2.1-18.apk" -Version "1.2.1"
#
# 手动补更新日志：脚本只插占位文字，发版后请把「（发版说明待补充）」改成真实的改动摘要。

param(
    [Parameter(Mandatory = $true)][string]$ApkPath,
    [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$siteDir = Join-Path $repoRoot 'site'
$indexPath = Join-Path $siteDir 'index.html'
$distDir = Join-Path $repoRoot 'dist'
$zipPath = Join-Path $distDir 'zhiji-site.zip'

if (-not (Test-Path $ApkPath)) {
    Write-Error "APK 不存在：$ApkPath"
    exit 1
}
if (-not (Test-Path $indexPath)) {
    Write-Error "site\index.html 不存在，网站目录还没建？"
    exit 1
}

# ---------- ① 清理旧 APK，放进新的 ----------
Get-ChildItem $siteDir -Filter '*.apk' | Remove-Item -Force

$newName = "zhiji_oil_v$Version.apk"
Copy-Item $ApkPath (Join-Path $siteDir $newName) -Force
$sizeMb = [math]::Round((Get-Item $ApkPath).Length / 1MB, 1)
Write-Host "  ① APK 已放进 site/：$newName（$sizeMb MB）"

# ---------- ② 改 index.html ----------
# UTF-8 无 BOM 是硬要求：带 BOM 的话 Cloudflare 会把 <!DOCTYPE> 前面的字节当文本渲染
$utf8 = New-Object System.Text.UTF8Encoding($false)
$html = [System.IO.File]::ReadAllText($indexPath, $utf8)

# a) 下载链接
$html = [regex]::Replace($html, 'zhiji_oil_v\d+(?:\.\d+)*\.apk', $newName)

# b) 版本号 + 体积文案（形如：v1.2.1 · 21 MB · Android 7.0 及以上 · 64 位）
$html = [regex]::Replace(
    $html,
    'v\d+(?:\.\d+)+ · [\d.]+ ?MB · Android 7\.0 及以上 · 64 位',
    "v$Version · $sizeMb MB · Android 7.0 及以上 · 64 位"
)

# c) 更新日志顶部插一行占位（只插一次：若该版本号已在日志里就跳过）
$logAnchor = '<div class="row">'
if ($html -notmatch [regex]::Escape("<div class=""v"">v$Version</div>")) {
    $newRow = @"
      <div class="row">
        <div class="v">v$Version</div>
        <div class="t">（发版说明待补充）</div>
      </div>
"@
    $pos = $html.IndexOf($logAnchor)
    if ($pos -ge 0) {
        $html = $html.Substring(0, $pos) + $newRow.TrimEnd() + "`n      " + $html.Substring($pos)
        Write-Host "  ② 更新日志已插入 v$Version 占位行"
    }
} else {
    Write-Host "  ② 更新日志已包含 v$Version，跳过"
}

[System.IO.File]::WriteAllText($indexPath, $html, $utf8)
Write-Host "  ② index.html 版本号/链接已更新"

# ---------- ③ 重新打包 ----------
if (-not (Test-Path $distDir)) { New-Item -ItemType Directory -Path $distDir | Out-Null }
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path (Join-Path $siteDir '*') -DestinationPath $zipPath -CompressionLevel Optimal
$zipMb = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
Write-Host "  ③ 部署包已生成：dist\zhiji-site.zip（$zipMb MB）"

# ---------- ④ 自检：还剩几个 apk、链接对不对 ----------
$apkCount = (Get-ChildItem $siteDir -Filter '*.apk').Count
$linkOk = ([System.IO.File]::ReadAllText($indexPath, $utf8)) -match [regex]::Escape($newName)
if ($apkCount -ne 1) {
    Write-Host "  ⚠ site/ 里有 $apkCount 个 APK（应该只有 1 个）" -ForegroundColor Yellow
}
if (-not $linkOk) {
    Write-Host "  ⚠ 首页里找不到 $newName 的链接" -ForegroundColor Yellow
} else {
    Write-Host "  ④ 自检通过：1 个 APK，链接指向 $newName"
}

Write-Host ""
Write-Host "  下一步：把 dist\zhiji-site.zip 拖到 Cloudflare Pages 重新部署" -ForegroundColor Green
Write-Host "  别忘了把更新日志里的「（发版说明待补充）」改成真实改动" -ForegroundColor Yellow
