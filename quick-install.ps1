# =============================================================================
# Hermes Agent Quick Install Script (User-Space -- No Admin Required)
# Supports: Windows (PowerShell 5.1+)
# Usage: .\quick-install.ps1
# =============================================================================

param(
    [switch]$SkipInstall,
    [switch]$Force
)

# Override execution policy for this process (required for irm | iex)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$ErrorActionPreference = 'Stop'

# --- Helpers ---
function Write-Info    { param($msg) Write-Host '[INFO] ' -ForegroundColor Cyan -NoNewline; Write-Host $msg }
function Write-Ok      { param($msg) Write-Host '[OK] ' -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn    { param($msg) Write-Host '[!] ' -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err     { param($msg) Write-Host '[ERROR] ' -ForegroundColor Red -NoNewline; Write-Host $msg; exit 1 }
function Write-Step    { param($msg) Write-Host ('`n=== {0} ===' -f $msg) -ForegroundColor Magenta }

# --- Python validation (Windows App Execution Alias detection) ---
function Test-PythonValid {
    $cmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $cmd = Get-Command python3 -ErrorAction SilentlyContinue
    }
    if (-not $cmd) { return $false }
    # Windows App Execution Aliases live in WindowsApps -- they are stubs, not real Python
    if ($cmd.Source -like '*WindowsApps*') { return $false }
    # Verify it actually runs
    try {
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $ver = & $cmd.Source --version 2>&1
        $ErrorActionPreference = $prevEAP
        if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne $null) { return $false }
        if ("$ver" -like '*was not found*') { return $false }
        return $true
    }
    catch { return $false }
}

# --- Banner ---
Write-Host ''
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host '   Hermes Agent Quick Install (User-Space -- No Admin)     ' -ForegroundColor Cyan
Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ''

# --- Detect Environment ---
$isWSL = $false
if (Test-Path '/proc/version') {
    try {
        $procVer = Get-Content '/proc/version' -ErrorAction SilentlyContinue
        if ($procVer -match 'microsoft|WSL') {
            $isWSL = $true
            Write-Info 'WSL environment detected -- Recommend using quick-install.sh in WSL instead'
            $reply = Read-Host 'Continue installing in Windows? (Y/n)'
            if ($reply -eq 'n' -or $reply -eq 'N') { exit 0 }
        }
    }
    catch { }
}

# --- User-space directories ---
$UserBin = Join-Path $env:USERPROFILE '.local\bin'
$NpmGlobal = Join-Path $env:USERPROFILE '.npm-global'
if (-not (Test-Path $UserBin)) { New-Item -ItemType Directory -Path $UserBin -Force | Out-Null }
if (-not (Test-Path $NpmGlobal)) { New-Item -ItemType Directory -Path $NpmGlobal -Force | Out-Null }

# =============================================================================
# Step 1: Check and Install Prerequisites (User-Space)
# =============================================================================
Write-Step 'Step 1: Check and Install Prerequisites (User-Space)'

# 1.1 PowerShell version
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5) {
    Write-Err "Requires PowerShell 5.1 or higher (current: $psVer)`nDownload PowerShell Core: https://aka.ms/powershell"
}
Write-Ok "PowerShell $psVer"

# 1.2 Internet connection (with proxy support)
try {
    # Detect system proxy
    $proxy = [System.Net.WebProxy]::GetDefaultProxy()
    if ($proxy -and $proxy.Address) {
        Write-Info "System proxy detected: $($proxy.Address)"
        $global:PSDefaultParameterValues = @{
            'Invoke-WebRequest:Proxy' = $proxy.Address
            'Invoke-WebRequest:ProxyUseDefaultCredentials' = $true
        }
    }

    $testConn = Invoke-WebRequest -Uri 'https://github.com' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Write-Ok 'Internet connection OK'
}
catch {
    Write-Err "Cannot connect to the internet.`nPlease check your Internet / Firewall / Proxy settings.`nIf your company uses a proxy, make sure it's configured in Internet Options."
}

# 1.3 Git (user-space)
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Warn 'git not found -- Installing in user-space...'

    # Downloading Git Portable
    $gitDir = Join-Path $env:USERPROFILE '.local\git'
    if (-not (Test-Path $gitDir)) { New-Item -ItemType Directory -Path $gitDir -Force | Out-Null }

    $gitUrl = 'https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.2/PortableGit-2.47.1.2-64-bit.7z.exe'
    $gitExe = Join-Path $gitDir 'PortableGit.7z.exe'

    Write-Info 'Downloading Git Portable (this may take 1-2 minutes)...'
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitExe -UseBasicParsing
        Write-Info 'Extracting Git...'
        Start-Process -FilePath $gitExe -ArgumentList ('-o"' + $gitDir + '"', '-y') -Wait -NoNewWindow

        # Add to PATH
        $gitBin = Join-Path $gitDir 'bin'
        $gitCmdDir = Join-Path $gitDir 'cmd'
        $env:Path = $gitBin + ';' + $gitCmdDir + ';' + $env:Path

        # Add to User PATH permanently
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*$gitDir*") {
            [System.Environment]::SetEnvironmentVariable('Path', ($gitBin + ';' + $gitCmdDir + ';' + $userPath), 'User')
        }

        # Clean up installer
        Remove-Item $gitExe -Force -ErrorAction SilentlyContinue

        Write-Ok 'Git Portable installed'
    }
    catch {
        Write-Err "Git download failed: $_`nPlease check your internet connection and try again."
    }
}
else {
    $gitVer = (git --version) -replace 'git version ', ''
    Write-Ok "git $gitVer"
}

# 1.4 Node.js v22+ (using nvm-windows or standalone)

# Refresh PATH from registry to get previously installed Node.js
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Warn 'Node.js not found -- Installing in user-space...'

    # Download Node.js portable (no admin required)
    $nodeDir = Join-Path $env:USERPROFILE '.local\node'
    if (-not (Test-Path $nodeDir)) { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }

    $nodeUrl = 'https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip'
    $nodeZip = Join-Path $nodeDir 'node.zip'

    Write-Info 'Downloading Node.js v22 portable (this may take 2-3 minutes)...'
    try {
        Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeZip -UseBasicParsing
        Write-Info 'Extracting Node.js...'
        Expand-Archive -Path $nodeZip -DestinationPath $nodeDir -Force

        # Move files from subfolder
        $nodeSubDir = Get-ChildItem -Path $nodeDir -Directory | Where-Object { $_.Name -like 'node-v*' } | Select-Object -First 1
        if ($nodeSubDir) {
            Get-ChildItem -Path $nodeSubDir.FullName | Copy-Item -Destination $nodeDir -Recurse -Force
            Remove-Item -Path $nodeSubDir.FullName -Recurse -Force
        }

        Remove-Item -Path $nodeZip -Force

        # Remove .ps1 files to avoid PowerShell execution policy issues
        Get-ChildItem -Path $nodeDir -Filter "*.ps1" -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue

        $env:Path = $nodeDir + ';' + $env:Path
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*$nodeDir*") {
            [System.Environment]::SetEnvironmentVariable('Path', ($nodeDir + ';' + $userPath), 'User')
        }

        Write-Ok 'Node.js v22 portable installed'
    }
    catch {
        Write-Err "Node.js installation failed: $_`nPlease check your internet connection and try again."
    }
}

# Check Node.js version
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = (node --version) -replace 'v', ''
    $nodeMajor = [int]($nodeVer -split '\.')[0]

    if ($nodeMajor -lt 22) {
        Write-Err "Node.js must be v22 or higher (current: v$nodeVer)"
    }
    Write-Ok "Node.js v$nodeVer"

    # 1.5 npm (use .cmd to avoid PowerShell execution policy issues)
    $npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if (-not $npmCmd) {
        $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    }
    if (-not $npmCmd) {
        Write-Err 'npm not found -- Reinstalling Node.js'
    }
    $npmVer = npm.cmd --version
    Write-Ok "npm $npmVer"
}
else {
    Write-Err 'Node.js installation failed'
}

# 1.6 Python 3.10+ (standalone or embeddable)

# Refresh PATH again to get previously installed Python
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$pythonIsValid = Test-PythonValid
if (-not $pythonIsValid) {
    Write-Warn 'Python 3 not found (or Windows Store alias detected) -- Installing in user-space...'

    # Download Python embeddable package
    $pythonDir = Join-Path $env:USERPROFILE '.local\python'
    if (-not (Test-Path $pythonDir)) { New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null }

    $pythonUrl = 'https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip'
    $pythonZip = Join-Path $pythonDir 'python.zip'

    Write-Info 'Downloading Python embeddable...'
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip -UseBasicParsing
        Write-Info 'Extracting Python...'
        Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force
        Remove-Item -Path $pythonZip -Force

        # Enable pip by fixing python311._pth
        $pthFile = Join-Path $pythonDir 'python311._pth'
        if (Test-Path $pthFile) {
            $pthContent = Get-Content $pthFile
            $pthContent = $pthContent -replace '#import site', 'import site'
            [System.IO.File]::WriteAllText($pthFile, ($pthContent -join "`r`n"))
        }

        # Install pip
        $getPipUrl = 'https://bootstrap.pypa.io/get-pip.py'
        $getPipFile = Join-Path $pythonDir 'get-pip.py'
        Invoke-WebRequest -Uri $getPipUrl -OutFile $getPipFile -UseBasicParsing

        $pythonExe = Join-Path $pythonDir 'python.exe'
        Start-Process -FilePath $pythonExe -ArgumentList $getPipFile -Wait -NoNewWindow

        $pythonScriptsDir = Join-Path $pythonDir 'Scripts'
        $env:Path = $pythonDir + ';' + $pythonScriptsDir + ';' + $env:Path
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*$pythonDir*") {
            [System.Environment]::SetEnvironmentVariable('Path', ($pythonDir + ';' + $pythonScriptsDir + ';' + $userPath), 'User')
        }

        Write-Ok 'Python embeddable installed'
    }
    catch {
        Write-Err "Python installation failed: $_`nPlease check your internet connection and try again.`nOr download manually from: https://python.org/downloads/"
    }
}

# Check Python version (using validation function to skip Windows Store aliases)
$pythonIsValid = Test-PythonValid

if ($pythonIsValid) {
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $pythonVer = (python --version 2>&1) -replace 'Python ', ''
    $ErrorActionPreference = $prevEAP
    $pythonParts = $pythonVer -split '\.'
    $pythonMajor = [int]$pythonParts[0]
    $pythonMinor = [int]$pythonParts[1]

    if ($pythonMajor -lt 3 -or ($pythonMajor -eq 3 -and $pythonMinor -lt 10)) {
        Write-Err "Python must be 3.10 or higher (current: $pythonVer)"
    }
    Write-Ok "Python $pythonVer"

    # 1.7 pip
    $pipCmd = Get-Command pip -ErrorAction SilentlyContinue
    if (-not $pipCmd) {
        $pipCmd = Get-Command pip3 -ErrorAction SilentlyContinue
    }

    if ($pipCmd) {
        $pipVer = (pip --version 2>&1) -replace 'pip ', '' -replace ' from .*', ''
        Write-Ok "pip $pipVer"
    }
    else {
        Write-Warn 'pip not found -- Installing...'
        python -m ensurepip --upgrade 2>$null
        Write-Ok 'pip installed'
    }
}
else {
    Write-Err 'Python installation failed'
}

# =============================================================================
# Step 2: Install uv (Python package manager)
# =============================================================================
Write-Step 'Step 2: Install uv (Python package manager)'

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$uvCmd = Get-Command uv -ErrorAction SilentlyContinue
if (-not $uvCmd) {
    Write-Warn 'uv not found -- Installing...'
    try {
        powershell -ExecutionPolicy ByPass -c 'irm https://astral.sh/uv/install.ps1 | iex'
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
        Write-Ok 'uv installed'
    }
    catch {
        Write-Warn 'uv installation failed -- Can install manually: irm https://astral.sh/uv/install.ps1 | iex'
    }
}
else {
    Write-Ok 'uv found'
}

# =============================================================================
# Step 2.5: Install Hermes Agent (git clone + development install)
# =============================================================================
Write-Step 'Step 2.5: Install Hermes Agent (full installation with UI)'

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue

if ($hermesCmd -and -not $SkipInstall -and -not $Force) {
    Write-Warn 'Found existing hermes installation'
    $reply = Read-Host 'Reinstall? (y/N)'
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Info 'Skipping installation -- Using existing hermes'
        $SkipInstall = $true
    }
}

if (-not $SkipInstall) {
    # Remove old uv tool installation if exists (it lacks UI components)
    $uvToolDir = Join-Path $env:APPDATA 'uv\tools\hermes-agent'
    if (Test-Path $uvToolDir) {
        Write-Warn 'Found old hermes installation (uv tool) -- Removing...'
        Write-Info 'Old installation lacks UI components (desktop, dashboard)'
        try {
            uv tool uninstall hermes-agent 2>&1 | Out-Null
            Write-Ok 'Old hermes removed'
        }
        catch {
            # Force remove if uv tool uninstall fails
            Remove-Item $uvToolDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Ok 'Old hermes removed (forced)'
        }
    }
    
    # Use git clone method to get full installation with UI components
    $hermesInstallDir = Join-Path $env:LOCALAPPDATA 'hermes\hermes-agent'
    
    Write-Info 'Installing hermes-agent with full UI support...'
    Write-Host ''
    
    # Clone or update repository
    if (Test-Path $hermesInstallDir) {
        Write-Info 'Updating existing hermes-agent repository...'
        try {
            Push-Location $hermesInstallDir
            git pull origin main 2>&1 | Out-Null
            Pop-Location
            Write-Ok 'Repository updated'
        }
        catch {
            Write-Warn 'Git pull failed -- Reinstalling...'
            Pop-Location  # Make sure we're out of the directory
            
            # Kill any git processes that might be holding the directory
            Get-Process git -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            
            # Remove directory with retry
            $retryCount = 0
            while ((Test-Path $hermesInstallDir) -and ($retryCount -lt 3)) {
                try {
                    Remove-Item $hermesInstallDir -Recurse -Force
                    break
                }
                catch {
                    $retryCount++
                    Start-Sleep -Seconds 2
                }
            }
            
            git clone --depth 1 https://github.com/NousResearch/hermes-agent.git $hermesInstallDir
        }
    }
    else {
        Write-Info 'Cloning hermes-agent repository...'
        $hermesParentDir = Join-Path $env:LOCALAPPDATA 'hermes'
        if (-not (Test-Path $hermesParentDir)) {
            New-Item -ItemType Directory -Path $hermesParentDir -Force | Out-Null
        }
        git clone --depth 1 https://github.com/NousResearch/hermes-agent.git $hermesInstallDir
    }
    
    # Create virtual environment and install
    Write-Info 'Setting up Python environment...'
    try {
        Push-Location $hermesInstallDir
        
        # Create venv if not exists
        $venvDir = Join-Path $hermesInstallDir 'venv'
        if (-not (Test-Path $venvDir)) {
            uv venv venv --python 3.11
        }
        
        # Activate venv
        $venvScripts = Join-Path $venvDir 'Scripts'
        $env:Path = $venvScripts + ';' + $env:Path
        
        # Install hermes with all extras (Python)
        Write-Info 'Installing hermes-agent Python packages...'
        uv pip install -e '.[all]' --quiet
        Write-Ok 'Python packages installed'
        
        # Install Node.js dependencies (required for dashboard, desktop, TUI)
        Write-Info 'Installing Node.js dependencies (dashboard, desktop, TUI)...'
        Write-Info 'This may take 5-10 minutes on first run...'
        
        # Always clean node_modules to avoid corruption
        $nodeModules = Join-Path $hermesInstallDir 'node_modules'
        if (Test-Path $nodeModules) {
            Write-Info 'Cleaning node_modules...'
            Remove-Item $nodeModules -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Use npm ci for clean install from package-lock.json
        # Note: use cmd /c to avoid PowerShell converting npm stderr warnings to terminating errors
        Write-Info 'Running npm ci (clean install)...'
        cmd /c "npm.cmd ci --no-fund --no-audit 2>nul 1>nul"
        if ($LASTEXITCODE -ne 0) {
            Write-Warn 'npm ci failed -- Falling back to npm install...'
            cmd /c "npm.cmd install --no-fund --no-audit 2>nul 1>nul"
        }
        Write-Ok 'Node.js dependencies installed'

        # Build web UI for dashboard (so it works immediately without rebuilding)
        Write-Info 'Building web UI for dashboard (this may take 1-2 minutes)...'
        cmd /c "npm.cmd run build -w web 2>nul"
        if ($LASTEXITCODE -eq 0) {
            Write-Ok 'Dashboard web UI built -- ready to use immediately'
        }
        else {
            Write-Warn 'Dashboard web UI build skipped -- will build on first launch'
        }

        # Pre-build desktop (Electron) so hermes desktop launches immediately
        Write-Info 'Pre-building desktop app (this may take 3-5 minutes)...'
        Push-Location (Join-Path $hermesInstallDir 'apps\desktop')
        cmd /c "npm.cmd install --no-fund --no-audit 2>nul 1>nul"
        cmd /c "npm.cmd run build 2>nul"
        if ($LASTEXITCODE -eq 0) {
            Write-Ok 'Desktop app built -- hermes desktop will launch immediately'
        }
        else {
            Write-Warn 'Desktop pre-build skipped -- will build on first launch'
        }
        Pop-Location

        Pop-Location
        
        # Add hermes to PATH
        $hermesBin = Join-Path $venvScripts 'hermes.exe'
        if (Test-Path $hermesBin) {
            $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
            if ($userPath -notlike "*$venvScripts*") {
                [System.Environment]::SetEnvironmentVariable('Path', ($venvScripts + ';' + $userPath), 'User')
                $env:Path = $venvScripts + ';' + $env:Path
            }
            Write-Ok "hermes installed at: $hermesBin"
            Write-Ok 'UI components included (desktop, dashboard, TUI)'
        }
        else {
            Write-Warn 'hermes executable not found in venv'
        }
    }
    catch {
        Write-Err "Hermes installation failed: $_`nTry installing manually:`n  cd $hermesInstallDir`n  uv pip install -e '.[all]'"
    }
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
    
    $hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
    if ($hermesCmd) {
        Write-Ok "hermes ready: $($hermesCmd.Source)"
    }
    else {
        Write-Warn 'hermes not in PATH yet -- Try opening new PowerShell and run script again'
        Write-Host ''
        Write-Host 'Or add to PATH manually:' -ForegroundColor Yellow
        Write-Host "  $venvScripts" -ForegroundColor White
    }
}

# =============================================================================
# Step 3: Install Antigravity CLI (agy) -- Free, uses Google Account
# =============================================================================
Write-Step 'Step 3: Install Antigravity CLI (agy)'

# Refresh PATH from registry to get previously installed agy
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

Write-Info 'Antigravity CLI (agy) uses Gemini free via Google Account'
Write-Info 'Good for fixing/repairing hermes when it has problems'
Write-Info '(Free tier has rate limit -- enough for fixing hermes)'

$agyCmd = Get-Command agy -ErrorAction SilentlyContinue
if ($agyCmd) {
    Write-Ok 'Found existing agy installation'
}
else {
    Write-Warn 'agy not found -- Installing...'

    try {
        irm https://antigravity.google/cli/install.ps1 | iex
        $agyBin = Join-Path $env:LOCALAPPDATA 'agy\bin'
        $env:Path = $agyBin + ';' + $env:Path

        # Add to User PATH permanently
        $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*agy*") {
            [System.Environment]::SetEnvironmentVariable('Path', ($agyBin + ';' + $userPath), 'User')
        }

        Write-Ok "agy installed -> $agyBin"
        Write-Ok 'Start agy for first time to login with Google Account'
    }
    catch {
        Write-Warn 'agy installation failed -- Can install manually later:'
        Write-Host '  PowerShell: irm https://antigravity.google/cli/install.ps1 | iex' -ForegroundColor Yellow
        Write-Host '  CMD: curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd' -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 4: Ask for API Keys and Telegram Bot Token
# =============================================================================
Write-Step 'Step 4: Ask for API Keys and Telegram Bot Token'

# 4.1 LiteLLM API Key (Course 0 - provided by instructor)
Write-Host ''
Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
Write-Host 'LiteLLM Proxy Configuration (Course 0):' -ForegroundColor Yellow
Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host '  Base URL: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1' -ForegroundColor White
Write-Host '  Model: qwen3.7-plus' -ForegroundColor White
Write-Host ''

$LiteLLMKey = Read-Host 'Paste LiteLLM API Key (or press Enter to skip)'

if (-not [string]::IsNullOrWhiteSpace($LiteLLMKey)) {
    Write-Ok 'Received LiteLLM API Key'
}
else {
    Write-Warn 'Skipping LiteLLM API Key -- Can use hermes setup later'
}

# 4.2 Telegram Bot Token
Write-Host ''
Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
Write-Host 'Create Telegram Bot Token (follow Slide Module 02):' -ForegroundColor Yellow
Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
Write-Host ''
Write-Host '  1. Open Telegram and search for @BotFather' -ForegroundColor White
Write-Host '  2. Send command /newbot' -ForegroundColor White
Write-Host '  3. Name the bot (e.g., Hermes Assistant)' -ForegroundColor White
Write-Host '  4. Set username (e.g., my_hermes_bot)' -ForegroundColor White
Write-Host '  5. Copy token from BotFather (format: 123456789:ABCdefGHI...)' -ForegroundColor Cyan
Write-Host ''

$TelegramToken = Read-Host 'Paste Telegram Bot Token (or press Enter to skip)'

$TelegramChatId = ''
if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    if ($TelegramToken -notmatch '^\d+:[A-Za-z0-9_-]+$') {
        Write-Warn 'Invalid token -- Please check again (should be 123456789:ABCdef...)'
    }
    else {
        Write-Ok 'Received Telegram Bot Token'

        # 4.3 Telegram Chat ID
        Write-Host ''
        Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
        Write-Host 'Find your Telegram Chat ID (so ONLY you can use the bot):' -ForegroundColor Yellow
        Write-Host '----------------------------------------------------------------' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '  1. Open Telegram and search for @userinfobot' -ForegroundColor White
        Write-Host '  2. Press Start or send /start' -ForegroundColor White
        Write-Host '  3. It will reply with your Id: (a number like 123456789)' -ForegroundColor Cyan
        Write-Host ''

        $TelegramChatId = Read-Host 'Paste your Chat ID number (or press Enter to skip)'

        if (-not [string]::IsNullOrWhiteSpace($TelegramChatId)) {
            if ($TelegramChatId -match '^\d+$') {
                Write-Ok "Chat ID set: $TelegramChatId -- Only you can use the bot"
            }
            else {
                Write-Warn 'Invalid Chat ID (should be numbers only) -- Skipping'
                $TelegramChatId = ''
            }
        }
        else {
            Write-Warn 'Skipping Chat ID -- Bot will not respond until you configure TELEGRAM_ALLOWED_USERS'
        }
    }
}
else {
    Write-Warn 'Skipping Telegram setup -- Can use hermes gateway setup later'
}

# =============================================================================
# Step 5: Configure Hermes
# =============================================================================
Write-Step 'Step 5: Configure Hermes'

# On Windows, hermes uses %LOCALAPPDATA%\hermes (not ~/.hermes)
$hermesDir = Join-Path $env:LOCALAPPDATA 'hermes'
if (-not (Test-Path $hermesDir)) {
    New-Item -ItemType Directory -Path $hermesDir -Force | Out-Null
}

$logsDir = Join-Path $hermesDir 'logs'
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$envFile = Join-Path $hermesDir '.env'

# Backup existing .env
if (Test-Path $envFile) {
    $backupFile = $envFile + '.backup.' + (Get-Date -Format 'yyyyMMddHHmmss')
    Copy-Item $envFile $backupFile
    Write-Info "Backed up original .env to $backupFile"
}

# Create new .env
$envContent = @"
# Hermes Agent Environment Variables
# Configured by quick-install.ps1 at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# LiteLLM Proxy (Course 0 - provided by instructor)
LITELLM_API_KEY=$LiteLLMKey

# Telegram Bot Token
TELEGRAM_BOT_TOKEN=$TelegramToken

# Telegram Authorization (only your Chat ID can use the bot)
TELEGRAM_ALLOWED_USERS=$TelegramChatId
"@

[System.IO.File]::WriteAllText($envFile, $envContent, [System.Text.UTF8Encoding]::new($false))
Write-Ok 'Created .env with API keys'

# Create config.yaml
$configFile = Join-Path $hermesDir 'config.yaml'
if (Test-Path $configFile) {
    $backupConfig = $configFile + '.backup.' + (Get-Date -Format 'yyyyMMddHHmmss')
    Copy-Item $configFile $backupConfig
    Write-Info 'Backed up original config.yaml'
}

$configContent = @"
# Hermes Agent Configuration
# Configured by quick-install.ps1 at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

model:
  provider: litellm
  default: qwen3.7-plus
  base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1

providers:
  litellm:
    api_key: $LiteLLMKey
    base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
    default_model: qwen3.7-plus
    models:
      qwen3.7-plus:
        context_length: 1000000
    transport: openai_chat

# Dashboard
dashboard:
  enabled: true
  port: 9119

# Security & Permissions
approvals:
  mode: off

# Telegram Gateway
telegram:
  reactions: true

security:
  redact_secrets: false

privacy:
  redact_pii: false
"@

[System.IO.File]::WriteAllText($configFile, $configContent, [System.Text.UTF8Encoding]::new($false))
Write-Ok 'Create config.yaml (using LiteLLM Proxy + qwen3.7-plus)'
Write-Ok 'Configured: approvals=off, reactions=true, redact_secrets=false, redact_pii=false'
Write-Ok 'Dashboard: http://localhost:9119'

# =============================================================================
# Step 6: Configure Auto-Start after reboot (Windows Task Scheduler)
# =============================================================================
Write-Step 'Step 6: Configure Auto-Start after reboot'

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

# Find hermes executable
$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
$hermesBin = $null
if ($hermesCmd) {
    $hermesBin = $hermesCmd.Source
}
else {
    $fallbackHermes = Join-Path $env:LOCALAPPDATA 'hermes\hermes-agent\venv\Scripts\hermes.exe'
    if (Test-Path $fallbackHermes) {
        $hermesBin = $fallbackHermes
    }
}

if (-not $hermesBin) {
    Write-Warn 'hermes executable not found -- Skipping auto-start setup'
}
else {
    Write-Info "Found hermes at: $hermesBin"

    # Create startup scripts
    $startupDir = Join-Path $env:LOCALAPPDATA 'hermes\startup'
    if (-not (Test-Path $startupDir)) {
        New-Item -ItemType Directory -Path $startupDir -Force | Out-Null
    }

    # Create batch file for gateway
    $gatewayBat = Join-Path $startupDir 'hermes-gateway.bat'
    $gatewayContent = "@echo off`r`n`"$hermesBin`" gateway start"
    [System.IO.File]::WriteAllText($gatewayBat, $gatewayContent)

    # Create batch file for dashboard
    $dashboardBat = Join-Path $startupDir 'hermes-dashboard.bat'
    $dashboardContent = "@echo off`r`n`"$hermesBin`" dashboard --no-open"
    [System.IO.File]::WriteAllText($dashboardBat, $dashboardContent)

    # Create Windows Task Scheduler tasks
    try {
        # Remove old tasks if exist
        schtasks /Delete /TN 'HermesGateway' /F 2>$null
        schtasks /Delete /TN 'HermesDashboard' /F 2>$null

        # Create task for gateway (run at logon)
        $action = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument ('/c "' + $gatewayBat + '"')
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 0)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited

        Register-ScheduledTask -TaskName 'HermesGateway' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Hermes Agent Telegram Gateway' -Force | Out-Null

        # Create task for dashboard (run at logon)
        $action2 = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument ('/c "' + $dashboardBat + '"')
        $trigger2 = New-ScheduledTaskTrigger -AtLogOn

        Register-ScheduledTask -TaskName 'HermesDashboard' -Action $action2 -Trigger $trigger2 -Settings $settings -Principal $principal -Description 'Hermes Agent Web Dashboard' -Force | Out-Null

        Write-Ok 'Create Windows Task Scheduler tasks'
        Write-Ok '  - HermesGateway (Telegram)'
        Write-Ok '  - HermesDashboard (Dashboard)'
        Write-Info 'Start services with: schtasks /Run /TN "HermesGateway" && schtasks /Run /TN "HermesDashboard"'
    }
    catch {
        Write-Warn 'Task Scheduler creation failed -- Using Startup Folder instead'

        # Use Startup Folder instead
        $startupFolder = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Startup')

        # Create shortcut for gateway
        $wsGateway = New-Object -ComObject WScript.Shell
        $shortcutGateway = $wsGateway.CreateShortcut("$startupFolder\HermesGateway.lnk")
        $shortcutGateway.TargetPath = 'cmd.exe'
        $shortcutGateway.Arguments = '/c "' + $gatewayBat + '"'
        $shortcutGateway.WindowStyle = 7  # Minimized
        $shortcutGateway.Save()

        # Create shortcut for dashboard
        $shortcutDashboard = $wsGateway.CreateShortcut("$startupFolder\HermesDashboard.lnk")
        $shortcutDashboard.TargetPath = 'cmd.exe'
        $shortcutDashboard.Arguments = '/c "' + $dashboardBat + '"'
        $shortcutDashboard.WindowStyle = 7  # Minimized
        $shortcutDashboard.Save()

        Write-Ok 'Created Startup Folder shortcuts'
        Write-Ok '  - HermesGateway.lnk (Telegram)'
        Write-Ok '  - HermesDashboard.lnk (Dashboard)'
    }
}

# =============================================================================
# Step 7: Verify Installation
# =============================================================================
Write-Step 'Step 7: Verify Installation'

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
if ($hermesCmd) {
    $hermesVer = hermes --version 2>$null
    Write-Ok "hermes ready to use: $hermesVer"
}
else {
    Write-Warn 'hermes not in PATH'
    Write-Host ''
    Write-Host 'Try one of the following:' -ForegroundColor Yellow
    Write-Host '  1. Open new PowerShell and try again' -ForegroundColor White
    Write-Host '  2. Or use full path:' -ForegroundColor White
    $hermesUvPath = Join-Path $env:LOCALAPPDATA 'hermes\hermes-agent\venv\Scripts\hermes.exe'
    Write-Host ('     & "' + $hermesUvPath + '"') -ForegroundColor White
}

# =============================================================================
# Step 8: Summary
# =============================================================================
Write-Step 'Installation Summary'

Write-Host ''
Write-Host '============================================================' -ForegroundColor Green
Write-Host '                  Installation Complete!                    ' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ''
Write-Host 'Installed in user-space (No Admin required):' -ForegroundColor Cyan
Write-Host '  - Node.js v22+ -> ~/.local/node/' -ForegroundColor White
Write-Host '  - Python 3.11+ -> ~/.local/python/' -ForegroundColor White
Write-Host '  - uv -> ~/.local/bin/' -ForegroundColor White
Write-Host '  - Hermes -> %LOCALAPPDATA%\hermes\hermes-agent (git clone)' -ForegroundColor White
Write-Host '  - agy -> ~/AppData/Local/agy/bin/' -ForegroundColor White
Write-Host ''
Write-Host 'Configuration:' -ForegroundColor Cyan
Write-Host '  - Model: qwen3.7-plus (via LiteLLM Proxy)' -ForegroundColor White
Write-Host '  - Dashboard: http://localhost:9119' -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    Write-Host '  - Telegram: Ready to use' -ForegroundColor Green
}
else {
    Write-Host '  - Telegram: Not configured yet' -ForegroundColor Yellow
}
Write-Host '  - Auto-start: After login' -ForegroundColor Green
Write-Host ''
Write-Host 'Commands to use:' -ForegroundColor Cyan
Write-Host ''
Write-Host '  hermes                          Start Hermes CLI (chat)' -ForegroundColor Yellow
Write-Host '  hermes model                    Change model' -ForegroundColor Yellow
Write-Host '  hermes doctor                   Diagnose problems' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Start Telegram Gateway + Dashboard:' -ForegroundColor Cyan
Write-Host '  schtasks /Run /TN "HermesGateway"' -ForegroundColor Yellow
Write-Host '  schtasks /Run /TN "HermesDashboard"' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Test functionality:' -ForegroundColor Cyan
Write-Host ''
Write-Host '  hermes' -ForegroundColor Yellow
Write-Host '  > Hello, what can you do' -ForegroundColor White
Write-Host ''

Write-Host ''
Write-Host 'Ready to start Course 0: Hermes + AI Harness!' -ForegroundColor Green
Write-Host ''

# --- Prompt to continue ---
Read-Host 'Press Enter to close this window'
