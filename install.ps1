<#
.SYNOPSIS
    Velotoma Media Engine - 1-Click Automated Windows Installer
.DESCRIPTION
    Usage (PowerShell / Windows Terminal):
      irm https://raw.githubusercontent.com/KrSnaGit112/OCU/main/install.ps1 | iex
#>
param(
    [switch]$Dev,
    [switch]$Interactive
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "    Velotoma Media Engine - 1-Click Windows Installer" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

if ($env:VELOTOMA_DEV -eq '1') { $Dev = $true }
$platformKey = if ($Dev) { 'windows_dev' } else { 'windows' }

$manifestUrls = @(
    "https://github.com/KrSnaGit112/OCU/releases/latest/download/release.json",
    "https://raw.githubusercontent.com/KrSnaGit112/OCU/main/release.json?t=$([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())"
)
Write-Host "[INFO] Fetching latest release metadata from GitHub..." -ForegroundColor Yellow

$manifest = $null
foreach ($u in $manifestUrls) {
    try {
        $manifest = Invoke-RestMethod -Uri $u -UseBasicParsing -TimeoutSec 20
        if ($manifest -and $manifest.version) { break }
    } catch { }
}
if (-not $manifest -or -not $manifest.version) {
    throw "Could not fetch release.json from GitHub OCU."
}
$version = $manifest.version
$pkg = $manifest.platforms.$platformKey
if (-not $pkg -or -not $pkg.fileName) {
    throw "No '$platformKey' installer entry found in release.json (version $version)."
}

$fileName = $pkg.fileName
$expectedSha = ($pkg.sha256 | Out-String).Trim().ToLowerInvariant()
$downloadUrl = if ($pkg.url -match '^https?://') {
    $pkg.url
} else {
    "https://github.com/KrSnaGit112/OCU/releases/download/v$version/$fileName"
}

$tempExe = Join-Path $env:TEMP "Velotoma_Setup_${version}_$([System.Guid]::NewGuid().ToString('N').Substring(0,6)).exe"

try {
    Write-Host "[INFO] Downloading $fileName (v$version)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempExe -UseBasicParsing -TimeoutSec 180

    if (-not (Test-Path $tempExe)) {
        throw "Download failed: temporary setup file missing."
    }

    if ($expectedSha) {
        Write-Host "[INFO] Verifying SHA-256 checksum..." -ForegroundColor Gray
        $actualSha = (Get-FileHash -Path $tempExe -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actualSha -ne $expectedSha) {
            throw "SHA-256 verification failed! Expected $expectedSha, got $actualSha"
        }
        Write-Host "[OK]   SHA-256 verified ($($actualSha.Substring(0,12))...)." -ForegroundColor Green
    }

    $installerArgs = if ($Interactive) {
        @('/NORESTART')
    } else {
        @('/SILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CLOSEAPPLICATIONS')
    }

    Write-Host "[INFO] Launching Velotoma Media Engine v$version setup..." -ForegroundColor Cyan
    $proc = Start-Process -FilePath $tempExe -ArgumentList $installerArgs -Wait -PassThru
    if ($proc.ExitCode -eq 0) {
        Write-Host ""
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host "  Velotoma Media Engine v$version installed successfully!" -ForegroundColor Green
        Write-Host "============================================================" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host "[WARN] Setup exited with code $($proc.ExitCode)." -ForegroundColor Yellow
        exit $proc.ExitCode
    }
}
finally {
    if (Test-Path $tempExe) {
        Remove-Item $tempExe -Force -ErrorAction SilentlyContinue
    }
}
