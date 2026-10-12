[CmdletBinding()]
param(
    [string]$Version,
    [string]$ReleaseName,
    [string]$Branch = "autoland",
    [string]$SrcDir,
    [string]$ReleaseDir
)

$ErrorActionPreference = "Stop"

if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) not found in PATH. Please install it (winget install GitHub.cli or scoop install gh) and run: gh auth login"
    exit 1
}

if ([string]::IsNullOrWhiteSpace($SrcDir)) {
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    $SrcDir = Join-Path $homeDir "mozilla-source/firefox"
}

if ([string]::IsNullOrWhiteSpace($ReleaseDir)) {
    $ReleaseDir = Join-Path $PSScriptRoot "..\release"
}

if ([string]::IsNullOrWhiteSpace($Version)) {
    $verFile = Join-Path $SrcDir "browser/config/version.txt"
    if (Test-Path $verFile) {
        $Version = (Get-Content $verFile).Trim()
    } else {
        Write-Error "Could not determine Firefox version from $verFile. Please specify VERSION=... when running task release."
        exit 1
    }
}

if ([string]::IsNullOrWhiteSpace($ReleaseName)) {
    switch ($Branch) {
        "autoland" { $ReleaseName = "nightly" }
        "beta"     { $ReleaseName = "beta" }
        default    { $ReleaseName = "stable" }
    }
}

if ($Version.EndsWith("-$ReleaseName")) {
    $tag = $Version
} else {
    $tag = "$Version-$ReleaseName"
}

Write-Host "Creating GitHub release for tag: $tag..."

$assets = Get-ChildItem -Path $ReleaseDir -File | Where-Object {
    $_.Name -like "*.win64.zip" -or $_.Name -like "*.win64.installer.exe" -or $_.Name -eq "package_name.txt"
}

if (!$assets) {
    Write-Error "No release artifacts found in $ReleaseDir. Run task package first."
    exit 1
}

$notes = @"
## Hellfire Windows Build

Optimized Windows build targeting x86-64-v3.

### Optimizations
- `-O3` Optimized
- Hardened Security
- Sandbox Enabled
- AVX2 + SSE4.2 support (x86-64-v3)

### Installation
- **Installer**: Download the `.exe` file and run it
- **Portable**: Extract the `.zip` file and run `hellfire.exe`

_Based on [CYFARE/HellFire](https://github.com/CYFARE/HellFire)_
"@

$assetPaths = $assets.FullName
gh release create $tag $assetPaths --title "Hellfire Windows $tag" --notes $notes
