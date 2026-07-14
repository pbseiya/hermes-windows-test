# =============================================================================
# Hermes Agent Quick Uninstall (User-Space -- No Admin)
# =============================================================================
# Usage: irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
# =============================================================================

$ErrorActionPreference = 'Continue'

function Write-Ok   { param($msg) Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Info  { param($msg) Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn  { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Step  { param($msg) Write-Host ("`n=== {0} ===" -f $msg) -ForegroundColor Magenta }

# Helper: Fast directory removal using robocopy trick
function Remove-Fast {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return }
    $emptyDir = Join-Path $env:TEMP 'empty_for_rmdir'
    if (-not (Test-Path $emptyDir)) { New-Item -ItemType Directory -Path $emptyDir -Force | Out-Null }
    cmd /c "robocopy `"$emptyDir`" `"$Path`" /MIR /NFL /NDL /NJH /NJS /nc /ns /np 2>nul"
    Remove-Item $Path -Force -ErrorAction SilentlyContinue
}

Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '   Hermes Agent Quick Uninstall (User-Space -- No Admin)' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# --- Step 1: Stop running processes ---
Write-Step 'Step 1: Stop running processes'

Get-Process -Name 'hermes','Hermes','pythonw' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {
    $_.Path -like '*hermes*' -and $_.ProcessName -ne 'powershell'
} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Ok 'Processes stopped'

# --- Step 2: Remove scheduled tasks ---
Write-Step 'Step 2: Remove scheduled tasks'

schtasks /Delete /TN 'HermesGateway' /F 2>$null
schtasks /Delete /TN 'HermesDashboard' /F 2>$null
schtasks /Delete /TN 'Hermes_Gateway' /F 2>$null
schtasks /Delete /TN 'Hermes_Dashboard' /F 2>$null
Write-Ok 'Scheduled tasks removed'

# --- Step 3: Remove startup shortcuts ---
Write-Step 'Step 3: Remove startup shortcuts'

$startupDir = [System.Environment]::GetFolderPath('Startup')
Get-ChildItem -Path $startupDir -Filter 'Hermes*' -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
Write-Ok 'Startup shortcuts removed'

# --- Step 4: Remove hermes installation (fast: robocopy all node_modules) ---
Write-Step 'Step 4: Remove hermes installation'

$hermesDir = Join-Path $env:LOCALAPPDATA 'hermes'
if (Test-Path $hermesDir) {
    Write-Info 'Removing hermes (using fast delete)...'

    # Fast-delete all node_modules directories (4 locations)
    $nodeModulesPaths = @(
        (Join-Path $hermesDir 'hermes-agent\node_modules'),
        (Join-Path $hermesDir 'hermes-agent\web\node_modules'),
        (Join-Path $hermesDir 'hermes-agent\apps\desktop\node_modules'),
        (Join-Path $hermesDir 'hermes-agent\ui-tui\node_modules')
    )
    foreach ($nm in $nodeModulesPaths) {
        if (Test-Path $nm) {
            Write-Info "  Cleaning: $($nm.Replace($hermesDir, ''))"
            Remove-Fast -Path $nm
        }
    }

    # Now remove the entire hermes directory (much faster after node_modules cleared)
    Remove-Item $hermesDir -Recurse -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $hermesDir)) {
        Write-Ok 'Hermes removed'
    } else {
        Write-Warn 'Some files could not be removed -- close all hermes processes and try again'
    }
} else {
    Write-Info 'Hermes not found -- skipping'
}

# --- Step 5: Remove portable tools (fast: robocopy) ---
Write-Step 'Step 5: Remove portable tools'

$dirsToRemove = @(
    @{ Name = 'Node.js'; Path = Join-Path $env:USERPROFILE '.local\node' },
    @{ Name = 'Git'; Path = Join-Path $env:USERPROFILE '.local\git' },
    @{ Name = 'Python'; Path = Join-Path $env:USERPROFILE '.local\python' },
    @{ Name = 'uv'; Path = Join-Path $env:USERPROFILE '.local\bin' },
    @{ Name = 'Antigravity (agy)'; Path = Join-Path $env:LOCALAPPDATA 'agy' }
)

foreach ($dir in $dirsToRemove) {
    if (Test-Path $dir.Path) {
        Remove-Fast -Path $dir.Path
        if (-not (Test-Path $dir.Path)) {
            Write-Ok "$($dir.Name) removed"
        } else {
            Write-Warn "$($dir.Name) -- some files locked"
        }
    } else {
        Write-Info "$($dir.Name) not found -- skipping"
    }
}

# Clean empty .local directory
$localDir = Join-Path $env:USERPROFILE '.local'
if ((Test-Path $localDir) -and ((Get-ChildItem $localDir -ErrorAction SilentlyContinue).Count -eq 0)) {
    Remove-Item $localDir -Force -ErrorAction SilentlyContinue
}

# --- Step 6: Clean PATH ---
Write-Step 'Step 6: Clean PATH environment variables'

$userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
$pathParts = $userPath -split ';' | Where-Object {
    $_ -ne '' -and
    $_ -notlike '*\.local\python*' -and
    $_ -notlike '*\.local\node*' -and
    $_ -notlike '*\.local\git*' -and
    $_ -notlike '*\.local\bin*' -and
    $_ -notlike '*\hermes*' -and
    $_ -notlike '*\agy*' -and
    $_ -notlike '*\nvm*' -and
    $_ -notlike '*\npm-global*'
}
$cleanPath = $pathParts -join ';'
if ($cleanPath -ne $userPath) {
    [System.Environment]::SetEnvironmentVariable('Path', $cleanPath, 'User')
    Write-Ok 'PATH cleaned'
} else {
    Write-Info 'PATH already clean'
}

# --- Step 7: Clean npm cache ---
Write-Step 'Step 7: Clean npm cache'

$npmCache = Join-Path $env:LOCALAPPDATA 'npm-cache'
if (Test-Path $npmCache) {
    Remove-Fast -Path $npmCache
    Write-Ok 'npm cache removed'
} else {
    Write-Info 'npm cache not found -- skipping'
}

# --- Cleanup temp ---
Remove-Item (Join-Path $env:TEMP 'empty_for_rmdir') -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $env:TEMP 'empty_for_uninstall') -Force -ErrorAction SilentlyContinue

# --- Summary ---
Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '                 Uninstall Complete!                        ' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Removed:' -ForegroundColor Cyan
Write-Host '  - Hermes Agent + all data' -ForegroundColor White
Write-Host '  - Node.js, Git, Python (portable)' -ForegroundColor White
Write-Host '  - uv, agy' -ForegroundColor White
Write-Host '  - Scheduled tasks + startup shortcuts' -ForegroundColor White
Write-Host '  - PATH entries' -ForegroundColor White
Write-Host '  - npm cache' -ForegroundColor White
Write-Host ''
Write-Host 'To reinstall, open a NEW PowerShell window and run:' -ForegroundColor Cyan
Write-Host '  irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex' -ForegroundColor Yellow
Write-Host ''

Read-Host 'Press Enter to close this window'
