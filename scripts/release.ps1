<#
.SYNOPSIS
    Automated Release Pipeline for Dodge the Creeps.
.DESCRIPTION
    1. Executes Godot 4.5 headless test suite to verify code health.
    2. Exports signed Android APK (locked to portrait orientation).
    3. Verifies Android manifest orientation badging via aapt2.
    4. Exports Windows Desktop x86_64 binary with embedded PCK.
    5. Packages Windows distribution archive (DodgeTheCreeps-Windows-x86_64.zip).
    6. Displays build summary with file sizes and SHA256 checksums.
    7. Optionally creates a Git version tag and pushes to trigger GitHub Actions.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\release.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\release.ps1 -Version "1.0.0" -TagAndPush
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [switch]$SkipTests,
    [switch]$TagAndPush,
    [string]$GodotPath = "C:\Users\DELL\Desktop\Godot_v4.5-stable_win64.exe"
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " DODGE THE CREEPS - AUTOMATED RELEASE PIPELINE" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Project Directory: $ProjectDir" -ForegroundColor DarkGray

# 1. Locate Godot binary
if (-not (Test-Path $GodotPath)) {
    $found = Get-Command "godot" -ErrorAction SilentlyContinue
    if ($found) {
        $GodotPath = $found.Source
    } else {
        throw "Godot executable not found at '$GodotPath' and not available in PATH."
    }
}
Write-Host "Using Godot Engine: $GodotPath" -ForegroundColor Green

function Invoke-Godot {
    param([string[]]$Arguments)
    $escapedArgs = foreach ($arg in $Arguments) {
        if ($arg -match '\s' -and -not ($arg.StartsWith('"') -and $arg.EndsWith('"'))) {
            "`"$arg`""
        } else {
            $arg
        }
    }
    $cmd = "`"$GodotPath`" $($escapedArgs -join ' ')"
    cmd.exe /c $cmd
    if ($LASTEXITCODE -ne 0) {
        throw "Godot command failed with exit code $LASTEXITCODE."
    }
}

# 2. Run Headless Automated Test Suite
if (-not $SkipTests) {
    Write-Host "`n[1/5] Running Automated Test Suite..." -ForegroundColor Yellow
    Invoke-Godot @("--headless", "--path", $ProjectDir, "--script", "res://tests/test_runner.gd")
    Write-Host "  -> All test suites passed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[1/5] Skipping tests as requested." -ForegroundColor DarkYellow
}

# 3. Prepare Export Directories
Write-Host "`n[2/5] Preparing export directories..." -ForegroundColor Yellow
$exportDir = Join-Path $ProjectDir "export"
$androidExportDir = Join-Path $exportDir "android"
$windowsExportDir = Join-Path $exportDir "windows"

New-Item -ItemType Directory -Force -Path $androidExportDir | Out-Null
New-Item -ItemType Directory -Force -Path $windowsExportDir | Out-Null

$apkPath = Join-Path $androidExportDir "DodgeTheCreeps.apk"
$exePath = Join-Path $windowsExportDir "DodgeTheCreeps.exe"
$zipPath = Join-Path $exportDir "DodgeTheCreeps-Windows-x86_64.zip"

# 4. Export Android APK
Write-Host "`n[3/5] Exporting signed Android APK (Portrait mode)..." -ForegroundColor Yellow
Invoke-Godot @("--headless", "--path", $ProjectDir, "--export-debug", "Android", "export/android/DodgeTheCreeps.apk")
if (-not (Test-Path $apkPath)) {
    throw "Android APK not found at expected path: $apkPath"
}

# Verify Android portrait badging with aapt2
$aapt2 = (Get-ChildItem -Path "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Filter "aapt2.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if ($aapt2 -and (Test-Path $aapt2)) {
    $badging = (cmd.exe /c "`"$aapt2`" dump badging `"$apkPath`" 2>nul") -join "`n"
    if ($badging -match "android\.hardware\.screen\.portrait") {
        Write-Host "  -> Confirmed Android orientation: PORTRAIT" -ForegroundColor Green
    } else {
        Write-Warning "Orientation badging did not explicitly match portrait."
    }
}
Write-Host "  -> Android APK export completed: $apkPath" -ForegroundColor Green

# 5. Export Windows Desktop & Package ZIP
Write-Host "`n[4/5] Exporting Windows Desktop executable & packaging ZIP..." -ForegroundColor Yellow
Invoke-Godot @("--headless", "--path", $ProjectDir, "--export-debug", "Windows Desktop", "export/windows/DodgeTheCreeps.exe")
if (-not (Test-Path $exePath)) {
    throw "Windows executable not found at expected path: $exePath"
}

# Compress Windows export
Compress-Archive -Path "$windowsExportDir\*" -DestinationPath $zipPath -Force
Write-Host "  -> Windows distribution archive created: $zipPath" -ForegroundColor Green

# 6. Build Summary Table
Write-Host "`n[5/5] Release Summary & Checksums:" -ForegroundColor Yellow
Write-Host "----------------------------------------------------------" -ForegroundColor DarkGray
$artifacts = @(
    (Get-Item $apkPath),
    (Get-Item $exePath),
    (Get-Item $zipPath)
)

$summary = foreach ($file in $artifacts) {
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
    [PSCustomObject]@{
        Artifact = $file.Name
        SizeMB   = [math]::Round($file.Length / 1MB, 2)
        SHA256   = "$($hash.Substring(0, 16))..."
        Path     = $file.FullName
    }
}
$summary | Format-Table -AutoSize

# 7. Optional Git Tag and Push
if ($TagAndPush) {
    if (-not $Version) {
        $Version = "1.0.0"
    }
    $tagName = if ($Version.StartsWith("v")) { $Version } else { "v$Version" }
    Write-Host "`nCreating Git tag '$tagName' and pushing to origin..." -ForegroundColor Yellow
    Set-Location $ProjectDir
    git tag -a $tagName -m "Release $tagName"
    git push origin main --tags
    Write-Host "Successfully pushed tag '$tagName'! GitHub Actions release workflow triggered." -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " RELEASE AUTOMATION FINISHED SUCCESSFULLY!" -ForegroundColor Cyan
Write-Host "==========================================================`n" -ForegroundColor Cyan
