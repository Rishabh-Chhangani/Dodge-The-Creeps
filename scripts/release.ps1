<#
.SYNOPSIS
    Automated Release & Tagging Pipeline for Dodge the Creeps.
.DESCRIPTION
    1. Automatically detects latest Git tag and computes the next semantic version (patch, minor, major).
    2. Automatically synchronizes version codes and versions in export_presets.cfg.
    3. Executes Godot 4.5 headless test suite to verify code health before exporting.
    4. Exports signed Android APK (locked to portrait orientation).
    5. Verifies Android manifest orientation badging via aapt2.
    6. Exports Windows Desktop x86_64 binary with embedded PCK.
    7. Packages Windows distribution archive (DodgeTheCreeps-Windows-x86_64.zip).
    8. Displays build summary with file sizes and SHA256 checksums.
    9. Automatically creates the Git version tag and pushes to origin with --tags to trigger GitHub Actions release.
.EXAMPLE
    scripts\release.bat
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\release.ps1
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\release.ps1 -Bump minor
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File scripts\release.ps1 -Version "1.2.0"
#>
[CmdletBinding()]
param(
    [ValidateSet("patch", "minor", "major")]
    [string]$Bump = "patch",
    [string]$Version = "",
    [switch]$SkipTests,
    [switch]$NoTag,
    [string]$GodotPath = "C:\Users\DELL\Desktop\Godot_v4.5-stable_win64.exe"
)

$ErrorActionPreference = "Stop"
$ProjectDir = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectDir

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

# 2. Determine Next Semantic Version & Tag
function Get-NextTag {
    param(
        [string]$ExplicitVersion,
        [string]$BumpType
    )
    if ($ExplicitVersion) {
        return if ($ExplicitVersion.StartsWith("v")) { $ExplicitVersion } else { "v$ExplicitVersion" }
    }
    
    # Fetch tags silently from remote
    cmd.exe /c "git fetch --tags --force 2>nul" | Out-Null
    $allTags = git tag -l "v*" --sort=-v:refname
    $latestTag = if ($allTags) { $allTags[0] } else { $null }

    if (-not $latestTag) {
        return "v1.0.0"
    }

    if ($latestTag -match '^v?(\d+)\.(\d+)\.(\d+)') {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]

        switch ($BumpType.ToLower()) {
            "major" { $major++; $minor = 0; $patch = 0 }
            "minor" { $minor++; $patch = 0 }
            default { $patch++ }
        }
        return "v$major.$minor.$patch"
    }

    return "v1.0.0"
}

$nextTag = Get-NextTag -ExplicitVersion $Version -BumpType $Bump
$semVer = $nextTag.TrimStart('v')
Write-Host "`nTarget Release Tag: $nextTag (Version $semVer, Bump: $Bump)" -ForegroundColor Magenta

# 3. Automatically Update Version in export_presets.cfg
$presetsPath = Join-Path $ProjectDir "export_presets.cfg"
if (Test-Path $presetsPath) {
    if ($semVer -match '^(\d+)\.(\d+)\.(\d+)') {
        $major = [int]$matches[1]
        $minor = [int]$matches[2]
        $patch = [int]$matches[3]
        $versionCode = ($major * 10000) + ($minor * 100) + $patch
        if ($versionCode -lt 1) { $versionCode = 1 }
        $peVersion = "$semVer.0"

        $cfg = Get-Content $presetsPath -Raw
        $cfg = $cfg -replace '(?m)^version/code=\d+', "version/code=$versionCode"
        $cfg = $cfg -replace '(?m)^version/name="[^"]*"', "version/name=`"$semVer`""
        $cfg = $cfg -replace '(?m)^application/file_version="[^"]*"', "application/file_version=`"$peVersion`""
        $cfg = $cfg -replace '(?m)^application/product_version="[^"]*"', "application/product_version=`"$peVersion`""
        Set-Content -Path $presetsPath -Value $cfg -NoNewline
        Write-Host "Synchronized export_presets.cfg: code=$versionCode, name=$semVer, pe=$peVersion" -ForegroundColor Green
    }
}

# 4. Run Headless Automated Test Suite
if (-not $SkipTests) {
    Write-Host "`n[1/5] Running Automated Test Suite..." -ForegroundColor Yellow
    Invoke-Godot @("--headless", "--path", $ProjectDir, "--script", "res://tests/test_runner.gd")
    Write-Host "  -> All test suites passed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[1/5] Skipping tests as requested." -ForegroundColor DarkYellow
}

# 5. Prepare Export Directories
Write-Host "`n[2/5] Preparing export directories..." -ForegroundColor Yellow
$exportDir = Join-Path $ProjectDir "export"
$androidExportDir = Join-Path $exportDir "android"
$windowsExportDir = Join-Path $exportDir "windows"

New-Item -ItemType Directory -Force -Path $androidExportDir | Out-Null
New-Item -ItemType Directory -Force -Path $windowsExportDir | Out-Null

$apkPath = Join-Path $androidExportDir "DodgeTheCreeps.apk"
$exePath = Join-Path $windowsExportDir "DodgeTheCreeps.exe"
$zipPath = Join-Path $exportDir "DodgeTheCreeps-Windows-x86_64.zip"

# 6. Export Android APK
Write-Host "`n[3/5] Exporting signed Android APK (Portrait mode)..." -ForegroundColor Yellow
Invoke-Godot @("--headless", "--path", $ProjectDir, "--export-debug", "Android", "export/android/DodgeTheCreeps.apk")
if (-not (Test-Path $apkPath)) {
    throw "Android APK not found at expected path: $apkPath"
}

# Verify Android portrait badging with aapt
$aapt = (Get-ChildItem -Path "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Filter "aapt.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $aapt) {
    $aapt = (Get-ChildItem -Path "$env:LOCALAPPDATA\Android\Sdk\build-tools" -Filter "aapt2.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if ($aapt -and (Test-Path $aapt)) {
    $badging = (cmd.exe /c "`"$aapt`" dump badging `"$apkPath`" 2>nul") -join "`n"
    if ($badging -match "android\.hardware\.screen\.portrait") {
        Write-Host "  -> Confirmed Android orientation: PORTRAIT" -ForegroundColor Green
    } else {
        Write-Warning "Orientation badging did not explicitly match portrait."
    }
}
Write-Host "  -> Android APK export completed: $apkPath" -ForegroundColor Green

# 7. Export Windows Desktop & Package ZIP
Write-Host "`n[4/5] Exporting Windows Desktop executable & packaging ZIP..." -ForegroundColor Yellow
Invoke-Godot @("--headless", "--path", $ProjectDir, "--export-debug", "Windows Desktop", "export/windows/DodgeTheCreeps.exe")
if (-not (Test-Path $exePath)) {
    throw "Windows executable not found at expected path: $exePath"
}

# Compress Windows export
Compress-Archive -Path "$windowsExportDir\*" -DestinationPath $zipPath -Force
Write-Host "  -> Windows distribution archive created: $zipPath" -ForegroundColor Green

# 8. Build Summary Table
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

# 9. Automated Git Tag and Push
if (-not $NoTag) {
    Write-Host "`n[Git Automation] Finalizing version commit and tag..." -ForegroundColor Yellow
    
    # Check if export_presets.cfg changed and commit it
    $diffStatus = git status --porcelain export_presets.cfg 2>$null
    if ($diffStatus) {
        git add export_presets.cfg
        git commit -m "chore(release): bump version to $semVer"
    }

    # Check if tag already exists locally or on remote
    $existingTag = git tag -l $nextTag
    if ($existingTag) {
        Write-Host "Tag $nextTag already exists locally. Updating tag to current HEAD..." -ForegroundColor DarkYellow
        git tag -d $nextTag | Out-Null
    }
    
    git tag -a $nextTag -m "Release $nextTag"
    Write-Host "Created tag '$nextTag'." -ForegroundColor Green

    Write-Host "Pushing branch and tags to origin..." -ForegroundColor Yellow
    git push origin main
    git push origin $nextTag --force
    Write-Host "Successfully pushed tag '$nextTag' to GitHub! CI/CD release workflow triggered." -ForegroundColor Green
} else {
    Write-Host "`n[Git Automation] Skipped tagging (-NoTag specified)." -ForegroundColor DarkGray
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host " RELEASE AUTOMATION & TAGGING COMPLETED!" -ForegroundColor Cyan
Write-Host "==========================================================`n" -ForegroundColor Cyan
