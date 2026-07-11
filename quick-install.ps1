# =============================================================================
# Hermes Agent Quick Install Script (User-Space — No Admin Required)
# Supports: Windows (PowerShell 5.1+)
# Usage: .\quick-install.ps1
# =============================================================================

param(
    [switch]$SkipInstall,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# --- Helpers ---
function Write-Info    { param($msg) Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline; Write-Host $msg }
function Write-Ok      { param($msg) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn    { param($msg) Write-Host "[!] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err     { param($msg) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $msg; exit 1 }
function Write-Step    { param($msg) Write-Host "`n━━━ $msg ━━━" -ForegroundColor Magenta }

# --- Banner ---
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Hermes Agent Quick Install (User-Space — No Admin)     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# --- Detect Environment ---
$isWSL = $false
if (Test-Path "/proc/version") {
    try {
        $procVer = Get-Content "/proc/version" -ErrorAction SilentlyContinue
        if ($procVer -match "microsoft|WSL") {
            $isWSL = $true
            Write-Info "WSL environment detected — Recommend using quick-install.sh in WSL instead"
            $reply = Read-Host "Continue installing in Windows? (Y/n)"
            if ($reply -eq 'n' -or $reply -eq 'N') { exit 0 }
        }
    } catch {}
}

# --- User-space directories ---
$UserBin = Join-Path $env:USERPROFILE ".local\bin"
$NpmGlobal = Join-Path $env:USERPROFILE ".npm-global"
if (-not (Test-Path $UserBin)) { New-Item -ItemType Directory -Path $UserBin -Force | Out-Null }
if (-not (Test-Path $NpmGlobal)) { New-Item -ItemType Directory -Path $NpmGlobal -Force | Out-Null }

# =============================================================================
# Step 1: Check and Install Prerequisites (User-Space)
# =============================================================================
Write-Step "Step 1: Check and Install Prerequisites (User-Space)"

# 1.1 PowerShell version
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5) {
    Write-Err "Requires PowerShell 5.1 or higher (current: $psVer)`nDownload PowerShell Core: https://aka.ms/powershell"
}
Write-Ok "PowerShell $psVer"

# 1.2 Internet connection
try {
    $testConn = Invoke-WebRequest -Uri "https://hermes-agent.nousresearch.com" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Ok "Internet connection OK"
} catch {
    Write-Err "Cannot connect to hermes-agent.nousresearch.com`nCheck Internet / Firewall / Proxy"
}

# 1.3 Git (user-space)
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Warn "git not found — Installing in user-space..."
    
    # Downloading Git Portable
    $gitDir = Join-Path $env:USERPROFILE ".local\git"
    if (-not (Test-Path $gitDir)) { New-Item -ItemType Directory -Path $gitDir -Force | Out-Null }
    
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/PortableGit-2.43.0-64-bit.7z.exe"
    $gitExe = Join-Path $gitDir "PortableGit.7z.exe"
    
    Write-Info "Downloading Git Portable..."
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitExe -UseBasicParsing
        Write-Info "Extracting Git..."
        Start-Process -FilePath $gitExe -ArgumentList "-o`"$gitDir`"", "-y" -Wait -NoNewWindow
        
        # Add to PATH
        $env:Path = "$gitDir\bin;$gitDir\cmd;$env:Path"
        
        # Add to User PATH permanently
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$gitDir*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$gitDir\bin;$gitDir\cmd;$userPath", "User")
        }
        
        Write-Ok "Git Portable installed"
    } catch {
        Write-Warn "Git download failed — Trying winget"
        try {
            winget install Git.Git --scope user --accept-source-agreements --accept-package-agreements --silent
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Ok "Git installed with winget"
        } catch {
            Write-Err "Git installation failed — Please install manually: https://git-scm.com/download/win"
        }
    }
} else {
    $gitVer = (git --version) -replace 'git version ', ''
    Write-Ok "git $gitVer"
}

# 1.4 Node.js v22+ (using nvm-windows or standalone)
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Warn "Node.js not found — Installing in user-space..."
    
    # Try nvm-windows first
    $nvmCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if (-not $nvmCmd) {
        Write-Info "Installing nvm-windows..."
        $nvmDir = Join-Path $env:USERPROFILE ".nvm"
        if (-not (Test-Path $nvmDir)) { New-Item -ItemType Directory -Path $nvmDir -Force | Out-Null }
        
        # Download nvm-setup.exe
        $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"
        $nvmExe = Join-Path $nvmDir "nvm-setup.exe"
        
        try {
            Invoke-WebRequest -Uri $nvmUrl -OutFile $nvmExe -UseBasicParsing
            Write-Info "Installing nvm-windows..."
            Start-Process -FilePath $nvmExe -ArgumentList "/S", "/D=$nvmDir" -Wait -NoNewWindow
            
            $env:Path = "$nvmDir;$env:Path"
            $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$nvmDir*") {
                [System.Environment]::SetEnvironmentVariable("Path", "$nvmDir;$userPath", "User")
            }
        } catch {
            Write-Warn "nvm installation failed — Downloading Node.js portable instead"
        }
    }
    
    # Install Node.js v22
    $nvmCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if ($nvmCmd) {
        Write-Info "Installing Node.js v22 with nvm..."
        nvm install 22.14.0
        nvm use 22.14.0
        Write-Ok "Node.js v22 installed with nvm"
    } else {
        # Downloading Node.js portable
        $nodeDir = Join-Path $env:USERPROFILE ".local\node"
        if (-not (Test-Path $nodeDir)) { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }
        
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip"
        $nodeZip = Join-Path $nodeDir "node.zip"
        
        Write-Info "Downloading Node.js portable..."
        try {
            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeZip -UseBasicParsing
            Write-Info "Extracting Node.js..."
            Expand-Archive -Path $nodeZip -DestinationPath $nodeDir -Force
            
            # Move files from subfolder
            $nodeSubDir = Get-ChildItem -Path $nodeDir -Directory | Where-Object { $_.Name -like "node-v*" } | Select-Object -First 1
            if ($nodeSubDir) {
                Get-ChildItem -Path $nodeSubDir.FullName | Copy-Item -Destination $nodeDir -Recurse -Force
                Remove-Item -Path $nodeSubDir.FullName -Recurse -Force
            }
            
            Remove-Item -Path $nodeZip -Force
            
            $env:Path = "$nodeDir;$env:Path"
            $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$nodeDir*") {
                [System.Environment]::SetEnvironmentVariable("Path", "$nodeDir;$userPath", "User")
            }
            
            Write-Ok "Node.js portable installed"
        } catch {
            Write-Err "Node.js installation failed — Please install manually: https://nodejs.org/"
        }
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
    
    # 1.5 npm
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npmCmd) {
        Write-Err "npm not found — Reinstalling Node.js"
    }
    $npmVer = npm --version
    Write-Ok "npm $npmVer"
} else {
    Write-Err "Node.js installation failed"
}

# 1.6 Python 3.10+ (standalone or embeddable)
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
    Write-Warn "Python 3 not found — Installing in user-space..."
    
    # Download Python embeddable package
    $pythonDir = Join-Path $env:USERPROFILE ".local\python"
    if (-not (Test-Path $pythonDir)) { New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null }
    
    $pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"
    $pythonZip = Join-Path $pythonDir "python.zip"
    
    Write-Info "Downloading Python embeddable..."
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip -UseBasicParsing
        Write-Info "Extracting Python..."
        Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force
        Remove-Item -Path $pythonZip -Force
        
        # Enable pip by fixing python311._pth
        $pthFile = Join-Path $pythonDir "python311._pth"
        if (Test-Path $pthFile) {
            $pthContent = Get-Content $pthFile
            $pthContent = $pthContent -replace '#import site', 'import site'
            $pthContent | Set-Content $pthFile
        }
        
        # Install pip
        $getPipUrl = "https://bootstrap.pypa.io/get-pip.py"
        $getPipFile = Join-Path $pythonDir "get-pip.py"
        Invoke-WebRequest -Uri $getPipUrl -OutFile $getPipFile -UseBasicParsing
        
        $pythonExe = Join-Path $pythonDir "python.exe"
        Start-Process -FilePath $pythonExe -ArgumentList $getPipFile -Wait -NoNewWindow
        
        $env:Path = "$pythonDir;$pythonDir\Scripts;$env:Path"
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$pythonDir*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$pythonDir;$pythonDir\Scripts;$userPath", "User")
        }
        
        Write-Ok "Python embeddable installed"
    } catch {
        Write-Warn "Python download failed — Trying winget"
        try {
            winget install Python.Python.3.11 --scope user --accept-source-agreements --accept-package-agreements --silent
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Ok "Python installed with winget"
        } catch {
            Write-Err "Python installation failed — Please install manually: https://python.org/"
        }
    }
}

# Check Python version
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if ($pythonCmd) {
    $pythonVer = (python --version 2>&1) -replace 'Python ', ''
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
    } else {
        Write-Warn "pip not found — Installing..."
        python -m ensurepip --upgrade 2>$null
        Write-Ok "pip installed"
    }
} else {
    Write-Err "Python installation failed"
}

# =============================================================================
# Step 2: Install Hermes Agent with npm (user-space)
# =============================================================================
Write-Step "Step 2: Install Hermes Agent (npm - user-space)"

# Set npm prefix to user-space
npm config set prefix $NpmGlobal
$env:Path = "$NpmGlobal;$env:Path"

# Add to User PATH permanently
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$NpmGlobal*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$NpmGlobal;$userPath", "User")
}

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue

if ($hermesCmd -and -not $SkipInstall -and -not $Force) {
    Write-Warn "Found existing hermes installation"
    $reply = Read-Host "Reinstall? (y/N)"
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Info "Skipping installation — Using existing hermes"
        $SkipInstall = $true
    }
}

if (-not $SkipInstall) {
    Write-Info "Installing @nousresearch/hermes-agent from npm..."
    Write-Host ""

    try {
        # Install globally in user-space
        npm install -g @nousresearch/hermes-agent
    } catch {
        Write-Err "Hermes installation failed: $_`nTry running this command manually:`n  npm install -g @nousresearch/hermes-agent"
    }

    # Refresh PATH
    $env:Path = "$NpmGlobal;" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
    if ($hermesCmd) {
        Write-Ok "hermes installed with npm: $($hermesCmd.Source)"
    } else {
        Write-Warn "hermes not in PATH yet — Try opening new PowerShell and run script again"
        Write-Host ""
        Write-Host "Or install manually:" -ForegroundColor Yellow
        Write-Host "  npm install -g @nousresearch/hermes-agent" -ForegroundColor White
    }
}

# =============================================================================
# Step 2.5: Install Antigravity CLI (agy) — Free, uses Google Account
# =============================================================================
Write-Step "Step 2.5: Install Antigravity CLI (agy)"

Write-Info "Antigravity CLI (agy) uses Gemini free via Google Account"
Write-Info "Good for fixing/repairing hermes when it has problems"
Write-Info "(Free tier has rate limit — enough for fixing hermes)"

$agyCmd = Get-Command agy -ErrorAction SilentlyContinue
if ($agyCmd) {
    Write-Ok "Found existing agy installation"
} else {
    Write-Warn "agy not found — Installing..."
    
    try {
        irm https://antigravity.google/cli/install.ps1 | iex
        $agyBin = "$env:LOCALAPPDATA\agy\bin"
        $env:Path = "$agyBin;$env:Path"
        
        # Add to User PATH permanently
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$agyBin*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$agyBin;$userPath", "User")
        }
        
        Write-Ok "agy installed → $agyBin"
        Write-Ok "Start agy for first time to login with Google Account"
    } catch {
        Write-Warn "agy installation failed — Can install manually later:"
        Write-Host "  PowerShell: irm https://antigravity.google/cli/install.ps1 | iex" -ForegroundColor Yellow
        Write-Host "  CMD: curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 3: Ask for API Keys and Telegram Bot Token
# =============================================================================
Write-Step "Step 3: Ask for API Keys and Telegram Bot Token"

# 3.1 LiteLLM API Key (Course 0 - provided by instructor)
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "LiteLLM Proxy Configuration (Course 0):" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Base URL: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1" -ForegroundColor White
Write-Host "  Model: qwen3.7-plus" -ForegroundColor White
Write-Host ""

$LiteLLMKey = Read-Host "Paste LiteLLM API Key (or press Enter to skip)"

if (-not [string]::IsNullOrWhiteSpace($LiteLLMKey)) {
    Write-Ok "Received LiteLLM API Key"
} else {
    Write-Warn "Skipping LiteLLM API Key — Can use hermes setup later"
}

# 3.2 Telegram Bot Token
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Create Telegram Bot Token (follow Slide Module 02):" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Open Telegram and search for @BotFather" -ForegroundColor White
Write-Host "  2. Send command /newbot" -ForegroundColor White
Write-Host "  3. Name the bot (e.g., 'Hermes Assistant')" -ForegroundColor White
Write-Host "  4. Set username (e.g., 'my_hermes_bot')" -ForegroundColor White
Write-Host "  5. Copy token from BotFather (format: 123456789:ABCdefGHI...)" -ForegroundColor Cyan
Write-Host ""

$TelegramToken = Read-Host "Paste Telegram Bot Token (or press Enter to skip)"

if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    if ($TelegramToken -notmatch '^\d+:[A-Za-z0-9_-]+$') {
        Write-Warn "Invalid token — Please check again (should be 123456789:ABCdef...)"
    } else {
        Write-Ok "Received Telegram Bot Token"
    }
} else {
    Write-Warn "Skipping Telegram setup — Can use hermes gateway setup later"
}

# =============================================================================
# Step 4: Configure Hermes
# =============================================================================
Write-Step "Step 4: Configure Hermes"

$hermesDir = Join-Path $env:USERPROFILE ".hermes"
if (-not (Test-Path $hermesDir)) {
    New-Item -ItemType Directory -Path $hermesDir -Force | Out-Null
}

$logsDir = Join-Path $hermesDir "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
}

$envFile = Join-Path $hermesDir ".env"

# Backup existing .env
if (Test-Path $envFile) {
    $backupFile = "$envFile.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
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
"@

[System.IO.File]::WriteAllText($envFile, $envContent, [System.Text.UTF8Encoding]::new($false))
Write-Ok "Created .env with API keys"

# Create config.yaml
$configFile = Join-Path $hermesDir "config.yaml"
if (Test-Path $configFile) {
    $backupConfig = "$configFile.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $configFile $backupConfig
    Write-Info "Backed up original config.yaml"
}

$configContent = @"
# Hermes Agent Configuration
# Configured by quick-install.ps1 at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# Model Configuration (using LiteLLM Proxy)
model:
  provider: custom:litellm
  default: qwen3.7-plus

providers:
  litellm:
    base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
    key_env: LITELLM_API_KEY
    transport: openai_chat

# Dashboard
dashboard:
  enabled: true
  port: 9119

# Security & Permissions
approvals:
  mode: off  # No command approval needed (YOLO mode)

# Telegram Gateway
telegram:
  reactions: true  # React immediately

security:
  redact_secrets: false  # Show credentials without hiding

privacy:
  redact_pii: false  # Show personal info (email, phone) without hiding
"@

[System.IO.File]::WriteAllText($configFile, $configContent, [System.Text.UTF8Encoding]::new($false))
Write-Ok "Create config.yaml (using LiteLLM Proxy + qwen3.7-plus)"
Write-Ok "Configured: approvals=off, reactions=true, redact_secrets=false, redact_pii=false"
Write-Ok "Dashboard: http://localhost:9119"

# =============================================================================
# Step 5: Configure Auto-Start after reboot (Windows Task Scheduler)
# =============================================================================
Write-Step "Step 5: Configure Auto-Start after reboot"

# Find hermes executable
$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
$hermesBin = $null
if ($hermesCmd) {
    $hermesBin = $hermesCmd.Source
} elseif (Test-Path "$NpmGlobal\hermes.cmd") {
    $hermesBin = "$NpmGlobal\hermes.cmd"
}

if (-not $hermesBin) {
    Write-Warn "hermes executable not found — Skipping auto-start setup"
} else {
    Write-Info "Found hermes at: $hermesBin"
    
    # Create startup scripts
    $startupDir = Join-Path $env:USERPROFILE ".hermes\startup"
    if (-not (Test-Path $startupDir)) {
        New-Item -ItemType Directory -Path $startupDir -Force | Out-Null
    }
    
    # Create batch file for gateway
    $gatewayBat = Join-Path $startupDir "hermes-gateway.bat"
    $gatewayContent = @"
@echo off
set PATH=$NpmGlobal;$env:Path
"$hermesBin" gateway start
"@
    $gatewayContent | Set-Content $gatewayBat -Encoding ASCII
    
    # Create batch file for dashboard
    $dashboardBat = Join-Path $startupDir "hermes-dashboard.bat"
    $dashboardContent = @"
@echo off
set PATH=$NpmGlobal;$env:Path
"$hermesBin" dashboard start
"@
    $dashboardContent | Set-Content $dashboardBat -Encoding ASCII
    
    # Create Windows Task Scheduler tasks
    try {
        # Remove old tasks if exist
        schtasks /Delete /TN "HermesGateway" /F 2>$null
        schtasks /Delete /TN "HermesDashboard" /F 2>$null
        
        # Create task for gateway (run at logon)
        $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$gatewayBat`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 0)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
        
        Register-ScheduledTask -TaskName "HermesGateway" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Hermes Agent Telegram Gateway" -Force | Out-Null
        
        # Create task for dashboard (run at logon)
        $action2 = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$dashboardBat`""
        $trigger2 = New-ScheduledTaskTrigger -AtLogOn
        
        Register-ScheduledTask -TaskName "HermesDashboard" -Action $action2 -Trigger $trigger2 -Settings $settings -Principal $principal -Description "Hermes Agent Web Dashboard" -Force | Out-Null
        
        Write-Ok "Create Windows Task Scheduler tasks"
        Write-Ok "  - HermesGateway (Telegram)"
        Write-Ok "  - HermesDashboard (Dashboard)"
        Write-Info "Start services with: schtasks /Run /TN `"HermesGateway`" && schtasks /Run /TN `"HermesDashboard`""
    } catch {
        Write-Warn "Task Scheduler creation failed — Using Startup Folder instead"
        
        # Use Startup Folder instead
        $startupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
        
        # Create shortcut for gateway
        $wsGateway = New-Object -ComObject WScript.Shell
        $shortcutGateway = $wsGateway.CreateShortcut("$startupFolder\HermesGateway.lnk")
        $shortcutGateway.TargetPath = "cmd.exe"
        $shortcutGateway.Arguments = "/c `"$gatewayBat`""
        $shortcutGateway.WindowStyle = 7  # Minimized
        $shortcutGateway.Save()
        
        # Create shortcut for dashboard
        $shortcutDashboard = $wsGateway.CreateShortcut("$startupFolder\HermesDashboard.lnk")
        $shortcutDashboard.TargetPath = "cmd.exe"
        $shortcutDashboard.Arguments = "/c `"$dashboardBat`""
        $shortcutDashboard.WindowStyle = 7  # Minimized
        $shortcutDashboard.Save()
        
        Write-Ok "Created Startup Folder shortcuts"
        Write-Ok "  - HermesGateway.lnk (Telegram)"
        Write-Ok "  - HermesDashboard.lnk (Dashboard)"
    }
}

# =============================================================================
# Step 6: Verify Installation
# =============================================================================
Write-Step "Step 6: Verify Installation"

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
if ($hermesCmd) {
    $hermesVer = hermes --version 2>$null
    Write-Ok "hermes ready to use: $hermesVer"
} else {
    Write-Warn "hermes not in PATH"
    Write-Host ""
    Write-Host "Try one of the following:" -ForegroundColor Yellow
    Write-Host "  1. Open new PowerShell and try again" -ForegroundColor White
    Write-Host "  2. Or use full path:" -ForegroundColor White
    Write-Host "     & `"$NpmGlobal\hermes.cmd`"" -ForegroundColor White
}

# =============================================================================
# Step 7: Summary
# =============================================================================
Write-Step "Installation Summary"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    Installation Complete!                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Installed in user-space (No Admin required):" -ForegroundColor Cyan
Write-Host "  - Git → ~/.local/git/" -ForegroundColor White
Write-Host "  - Node.js v22+ → ~/.nvm/ or ~/.local/node/" -ForegroundColor White
Write-Host "  - Python 3.11+ → ~/.local/python/" -ForegroundColor White
Write-Host "  - npm global → ~/.npm-global/" -ForegroundColor White
Write-Host "  - Hermes → ~/.npm-global/hermes.cmd" -ForegroundColor White
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  - Model: qwen3.7-plus (via LiteLLM Proxy)" -ForegroundColor White
Write-Host "  - Dashboard: http://localhost:9119" -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    Write-Host "  - Telegram: Ready to use" -ForegroundColor Green
} else {
    Write-Host "  - Telegram: Not configured yet" -ForegroundColor Yellow
}
Write-Host "  - Auto-start: After login" -ForegroundColor Green
Write-Host ""
Write-Host "Commands to use:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  hermes                          Start Hermes CLI (chat)" -ForegroundColor Yellow
Write-Host "  hermes model                    Change model" -ForegroundColor Yellow
Write-Host "  hermes doctor                   Diagnose problems" -ForegroundColor Yellow
Write-Host ""
Write-Host "Start Telegram Gateway + Dashboard:" -ForegroundColor Cyan
Write-Host "  schtasks /Run /TN `"HermesGateway`"" -ForegroundColor Yellow
Write-Host "  schtasks /Run /TN `"HermesDashboard`"" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test functionality:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  hermes" -ForegroundColor Yellow
Write-Host "  > Hello, what can you do" -ForegroundColor White
Write-Host ""

Write-Host ""
Write-Host "Ready to start Course 0: Hermes + AI Harness!" -ForegroundColor Green
Write-Host ""

# --- Prompt to continue ---
Read-Host "Press Enter to close this window"
