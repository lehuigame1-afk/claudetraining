# Recomputes the SHA-256 hashes in index.html's Content-Security-Policy meta tag.
# Run this after ANY edit to the <script> or <style> block, otherwise the browser will block them:
#   powershell -ExecutionPolicy Bypass -File tools/update-csp.ps1
$path = Join-Path (Split-Path $PSScriptRoot -Parent) "index.html"
$html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
function Get-Hash([string]$text) {
  $text = $text -replace "`r`n", "`n"   # the HTML parser normalises CRLF before hashing
  $sha = [System.Security.Cryptography.SHA256]::Create()
  "'sha256-" + [Convert]::ToBase64String($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text))) + "'"
}
$scripts = ([regex]::Matches($html, "<script>([\s\S]*?)</script>") | ForEach-Object { Get-Hash $_.Groups[1].Value }) -join " "
$style  = [regex]::Match($html, "<style>([\s\S]*?)</style>").Groups[1].Value
$html = [regex]::Replace($html, "script-src ('[^']*'\s*)+;", "script-src $scripts;")
$html = [regex]::Replace($html, "style-src '[^']*'",  "style-src $(Get-Hash $style)")
[System.IO.File]::WriteAllText($path, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "CSP hashes updated in $path"
