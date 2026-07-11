# =============================================================================
# Hermes Agent Quick Install Script (User-Space — ไม่ต้อง Admin)
# รองรับ: Windows (PowerShell 5.1+)
# วิธีใช้: .\quick-install.ps1 [-OpenRouterKey "sk-or-v1-..."]
# =============================================================================

param(
    [string]$OpenRouterKey = "",
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
            Write-Info "ตรวจพบ WSL environment — แนะนำใช้ quick-install.sh ใน WSL แทน"
            $reply = Read-Host "ต้องการติดตั้งใน Windows ต่อไปไหม? (Y/n)"
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
# Step 1: ตรวจสอบและติดตั้ง Prerequisites (User-Space)
# =============================================================================
Write-Step "Step 1: ตรวจสอบและติดตั้ง Prerequisites (User-Space)"

# 1.1 PowerShell version
$psVer = $PSVersionTable.PSVersion
if ($psVer.Major -lt 5) {
    Write-Err "ต้องมี PowerShell 5.1 ขึ้นไป (ปัจจุบัน: $psVer)`nดาวน์โหลด PowerShell Core: https://aka.ms/powershell"
}
Write-Ok "PowerShell $psVer"

# 1.2 Internet connection
try {
    $testConn = Invoke-WebRequest -Uri "https://hermes-agent.nousresearch.com" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Ok "เชื่อมต่อ Internet ได้"
} catch {
    Write-Err "ไม่สามารถเชื่อมต่อ hermes-agent.nousresearch.com ได้`nตรวจสอบ Internet / Firewall / Proxy"
}

# 1.3 Git (user-space)
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Warn "ไม่พบ git — กำลังติดตั้งใน user-space..."
    
    # ดาวน์โหลด Git Portable
    $gitDir = Join-Path $env:USERPROFILE ".local\git"
    if (-not (Test-Path $gitDir)) { New-Item -ItemType Directory -Path $gitDir -Force | Out-Null }
    
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/PortableGit-2.43.0-64-bit.7z.exe"
    $gitExe = Join-Path $gitDir "PortableGit.7z.exe"
    
    Write-Info "ดาวน์โหลด Git Portable..."
    try {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitExe -UseBasicParsing
        Write-Info "แตกไฟล์ Git..."
        Start-Process -FilePath $gitExe -ArgumentList "-o`"$gitDir`"", "-y" -Wait -NoNewWindow
        
        # เพิ่ม PATH
        $env:Path = "$gitDir\bin;$gitDir\cmd;$env:Path"
        
        # เพิ่มใน User PATH ถาวร
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$gitDir*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$gitDir\bin;$gitDir\cmd;$userPath", "User")
        }
        
        Write-Ok "Git Portable ติดตั้งแล้ว"
    } catch {
        Write-Warn "ดาวน์โหลด Git ไม่สำเร็จ — ลองใช้ winget"
        try {
            winget install Git.Git --scope user --accept-source-agreements --accept-package-agreements --silent
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Ok "Git ติดตั้งด้วย winget"
        } catch {
            Write-Err "ติดตั้ง Git ไม่สำเร็จ — กรุณาติดตั้งเอง: https://git-scm.com/download/win"
        }
    }
} else {
    $gitVer = (git --version) -replace 'git version ', ''
    Write-Ok "git $gitVer"
}

# 1.4 Node.js v22+ (ใช้ nvm-windows หรือ standalone)
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Warn "ไม่พบ Node.js — กำลังติดตั้งใน user-space..."
    
    # ลองใช้ nvm-windows ก่อน
    $nvmCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if (-not $nvmCmd) {
        Write-Info "ติดตั้ง nvm-windows..."
        $nvmDir = Join-Path $env:USERPROFILE ".nvm"
        if (-not (Test-Path $nvmDir)) { New-Item -ItemType Directory -Path $nvmDir -Force | Out-Null }
        
        # ดาวน์โหลด nvm-setup.exe
        $nvmUrl = "https://github.com/coreybutler/nvm-windows/releases/download/1.1.12/nvm-setup.exe"
        $nvmExe = Join-Path $nvmDir "nvm-setup.exe"
        
        try {
            Invoke-WebRequest -Uri $nvmUrl -OutFile $nvmExe -UseBasicParsing
            Write-Info "ติดตั้ง nvm-windows..."
            Start-Process -FilePath $nvmExe -ArgumentList "/S", "/D=$nvmDir" -Wait -NoNewWindow
            
            $env:Path = "$nvmDir;$env:Path"
            $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
            if ($userPath -notlike "*$nvmDir*") {
                [System.Environment]::SetEnvironmentVariable("Path", "$nvmDir;$userPath", "User")
            }
        } catch {
            Write-Warn "ติดตั้ง nvm ไม่สำเร็จ — ดาวน์โหลด Node.js portable แทน"
        }
    }
    
    # ติดตั้ง Node.js v22
    $nvmCmd = Get-Command nvm -ErrorAction SilentlyContinue
    if ($nvmCmd) {
        Write-Info "ติดตั้ง Node.js v22 ด้วย nvm..."
        nvm install 22.14.0
        nvm use 22.14.0
        Write-Ok "Node.js v22 ติดตั้งด้วย nvm"
    } else {
        # ดาวน์โหลด Node.js portable
        $nodeDir = Join-Path $env:USERPROFILE ".local\node"
        if (-not (Test-Path $nodeDir)) { New-Item -ItemType Directory -Path $nodeDir -Force | Out-Null }
        
        $nodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-x64.zip"
        $nodeZip = Join-Path $nodeDir "node.zip"
        
        Write-Info "ดาวน์โหลด Node.js portable..."
        try {
            Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeZip -UseBasicParsing
            Write-Info "แตกไฟล์ Node.js..."
            Expand-Archive -Path $nodeZip -DestinationPath $nodeDir -Force
            
            # ย้ายไฟล์จาก subfolder
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
            
            Write-Ok "Node.js portable ติดตั้งแล้ว"
        } catch {
            Write-Err "ติดตั้ง Node.js ไม่สำเร็จ — กรุณาติดตั้งเอง: https://nodejs.org/"
        }
    }
}

# ตรวจสอบ Node.js version
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVer = (node --version) -replace 'v', ''
    $nodeMajor = [int]($nodeVer -split '\.')[0]
    
    if ($nodeMajor -lt 22) {
        Write-Err "Node.js ต้อง v22 ขึ้นไป (ปัจจุบัน: v$nodeVer)"
    }
    Write-Ok "Node.js v$nodeVer"
    
    # 1.5 npm
    $npmCmd = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npmCmd) {
        Write-Err "ไม่พบ npm — ติดตั้ง Node.js ใหม่"
    }
    $npmVer = npm --version
    Write-Ok "npm $npmVer"
} else {
    Write-Err "ติดตั้ง Node.js ไม่สำเร็จ"
}

# 1.6 Python 3.10+ (standalone หรือ embeddable)
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
    Write-Warn "ไม่พบ Python 3 — กำลังติดตั้งใน user-space..."
    
    # ดาวน์โหลด Python embeddable package
    $pythonDir = Join-Path $env:USERPROFILE ".local\python"
    if (-not (Test-Path $pythonDir)) { New-Item -ItemType Directory -Path $pythonDir -Force | Out-Null }
    
    $pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip"
    $pythonZip = Join-Path $pythonDir "python.zip"
    
    Write-Info "ดาวน์โหลด Python embeddable..."
    try {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonZip -UseBasicParsing
        Write-Info "แตกไฟล์ Python..."
        Expand-Archive -Path $pythonZip -DestinationPath $pythonDir -Force
        Remove-Item -Path $pythonZip -Force
        
        # เปิดใช้งาน pip โดยแก้ไข python311._pth
        $pthFile = Join-Path $pythonDir "python311._pth"
        if (Test-Path $pthFile) {
            $pthContent = Get-Content $pthFile
            $pthContent = $pthContent -replace '#import site', 'import site'
            $pthContent | Set-Content $pthFile
        }
        
        # ติดตั้ง pip
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
        
        Write-Ok "Python embeddable ติดตั้งแล้ว"
    } catch {
        Write-Warn "ดาวน์โหลด Python ไม่สำเร็จ — ลองใช้ winget"
        try {
            winget install Python.Python.3.11 --scope user --accept-source-agreements --accept-package-agreements --silent
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            Write-Ok "Python ติดตั้งด้วย winget"
        } catch {
            Write-Err "ติดตั้ง Python ไม่สำเร็จ — กรุณาติดตั้งเอง: https://python.org/"
        }
    }
}

# ตรวจสอบ Python version
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
        Write-Err "Python ต้อง 3.10 ขึ้นไป (ปัจจุบัน: $pythonVer)"
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
        Write-Warn "ไม่พบ pip — กำลังติดตั้ง..."
        python -m ensurepip --upgrade 2>$null
        Write-Ok "pip installed"
    }
} else {
    Write-Err "ติดตั้ง Python ไม่สำเร็จ"
}

# =============================================================================
# Step 2: ติดตั้ง Hermes Agent ด้วย npm (user-space)
# =============================================================================
Write-Step "Step 2: ติดตั้ง Hermes Agent (npm — user-space)"

# ตั้งค่า npm prefix เป็น user-space
npm config set prefix $NpmGlobal
$env:Path = "$NpmGlobal;$env:Path"

# เพิ่มใน User PATH ถาวร
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$NpmGlobal*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$NpmGlobal;$userPath", "User")
}

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue

if ($hermesCmd -and -not $SkipInstall -and -not $Force) {
    Write-Warn "พบ hermes ที่ติดตั้งอยู่แล้ว"
    $reply = Read-Host "ต้องการติดตั้งทับไหม? (y/N)"
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Info "ข้ามการติดตั้ง — ใช้ hermes ที่มีอยู่แล้ว"
        $SkipInstall = $true
    }
}

if (-not $SkipInstall) {
    Write-Info "กำลังติดตั้ง @nousresearch/hermes-agent จาก npm..."
    Write-Host ""

    try {
        # ติดตั้งแบบ global ใน user-space
        npm install -g @nousresearch/hermes-agent
    } catch {
        Write-Err "ติดตั้ง Hermes ล้มเหลว: $_`nลองรันคำสั่งนี้ด้วยตัวเอง:`n  npm install -g @nousresearch/hermes-agent"
    }

    # Refresh PATH
    $env:Path = "$NpmGlobal;" + [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
    if ($hermesCmd) {
        Write-Ok "hermes ติดตั้งสำเร็จด้วย npm: $($hermesCmd.Source)"
    } else {
        Write-Warn "hermes ยังไม่อยู่ใน PATH — ลองเปิด PowerShell ใหม่แล้วรันสคริปต์อีกครั้ง"
        Write-Host ""
        Write-Host "หรือติดตั้งด้วยตัวเอง:" -ForegroundColor Yellow
        Write-Host "  npm install -g @nousresearch/hermes-agent" -ForegroundColor White
    }
}

# =============================================================================
# Step 2.5: ติดตั้ง Antigravity CLI (agy) — ฟรี ใช้ Google Account
# =============================================================================
Write-Step "Step 2.5: ติดตั้ง Antigravity CLI (agy)"

Write-Info "Antigravity CLI (agy) ใช้ Gemini ฟรี ผ่าน Google Account"
Write-Info "เหมาะสำหรับแก้ไข/ซ่อม hermes เมื่อ hermes มีปัญหา"
Write-Info "(Free tier มี rate limit — เพียงพอสำหรับการซ่อม hermes)"

$agyCmd = Get-Command agy -ErrorAction SilentlyContinue
if ($agyCmd) {
    Write-Ok "พบ agy ที่ติดตั้งอยู่แล้ว"
} else {
    Write-Warn "ไม่พบ agy — กำลังติดตั้ง..."
    
    try {
        irm https://antigravity.google/cli/install.ps1 | iex
        $agyBin = "$env:LOCALAPPDATA\agy\bin"
        $env:Path = "$agyBin;$env:Path"
        
        # เพิ่มใน User PATH ถาวร
        $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$agyBin*") {
            [System.Environment]::SetEnvironmentVariable("Path", "$agyBin;$userPath", "User")
        }
        
        Write-Ok "agy ติดตั้งสำเร็จ → $agyBin"
        Write-Ok "เริ่ม agy ครั้งแรกเพื่อ login ด้วย Google Account"
    } catch {
        Write-Warn "ติดตั้ง agy ไม่สำเร็จ — ติดตั้งเองทีหลังได้:"
        Write-Host "  PowerShell: irm https://antigravity.google/cli/install.ps1 | iex" -ForegroundColor Yellow
        Write-Host "  CMD: curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd" -ForegroundColor Yellow
    }
}

# =============================================================================
# Step 3: ถาม API Keys และ Telegram Bot Token
# =============================================================================
Write-Step "Step 3: ถาม API Keys และ Telegram Bot Token"

# 3.1 OpenRouter API Key
if ([string]::IsNullOrWhiteSpace($OpenRouterKey)) {
    Write-Warn "ยังไม่ได้ระบุ OpenRouter API Key"
    Write-Host ""
    Write-Host "สมัครฟรีที่:" -ForegroundColor Yellow
    Write-Host "  https://openrouter.ai/keys" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ขั้นตอน:" -ForegroundColor Yellow
    Write-Host "  1. เปิดลิงก์ด้านบน" -ForegroundColor White
    Write-Host "  2. คลิก 'Sign in with Google' (ใช้ Google Account ที่มีอยู่แล้ว)" -ForegroundColor White
    Write-Host "  3. คลิก '+ Create Key'" -ForegroundColor White
    Write-Host "  4. ตั้งชื่อ key (เช่น 'Hermes Course')" -ForegroundColor White
    Write-Host "  5. Copy key (ขึ้นต้นด้วย sk-or-v1-...)" -ForegroundColor White
    Write-Host ""

    # เปิด browser อัตโนมัติ
    $openBrowser = Read-Host "เปิดหน้าสมัคร OpenRouter ใน browser เลยไหม? (Y/n)"
    if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
        Start-Process "https://openrouter.ai/keys"
        Write-Info "เปิด browser แล้ว — สมัครสมาชิกแล้ว copy API Key มาวางด้านล่าง"
        Start-Sleep -Seconds 2
    }

    $OpenRouterKey = Read-Host "วาง OpenRouter API Key (หรือกด Enter เพื่อข้าม)"
}

if (-not [string]::IsNullOrWhiteSpace($OpenRouterKey)) {
    if ($OpenRouterKey -notmatch '^sk-or-') {
        Write-Warn "Key ไม่ขึ้นต้นด้วย sk-or- — ตรวจสอบอีกครั้ง"
    } else {
        Write-Ok "ได้รับ OpenRouter API Key"
    }
} else {
    Write-Warn "ข้ามการตั้งค่า API Key — ใช้ hermes setup ทีหลังได้"
}

# 3.2 Telegram Bot Token
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "สร้าง Telegram Bot Token (ทำตาม Slide Module 02):" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. เปิด Telegram แล้วค้นหา @BotFather" -ForegroundColor White
Write-Host "  2. ส่งคำสั่ง /newbot" -ForegroundColor White
Write-Host "  3. ตั้งชื่อ bot (เช่น 'Hermes Assistant')" -ForegroundColor White
Write-Host "  4. ตั้ง username (เช่น 'my_hermes_bot')" -ForegroundColor White
Write-Host "  5. Copy token ที่ BotFather ให้ (รูปแบบ: 123456789:ABCdefGHI...)" -ForegroundColor Cyan
Write-Host ""

$TelegramToken = Read-Host "วาง Telegram Bot Token (หรือกด Enter เพื่อข้าม)"

if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    if ($TelegramToken -notmatch '^\d+:[A-Za-z0-9_-]+$') {
        Write-Warn "Token ไม่ถูกต้อง — ตรวจสอบอีกครั้ง (ควรเป็น 123456789:ABCdef...)"
    } else {
        Write-Ok "ได้รับ Telegram Bot Token"
    }
} else {
    Write-Warn "ข้ามการตั้งค่า Telegram — ใช้ hermes gateway setup ทีหลังได้"
}

# =============================================================================
# Step 4: ตั้งค่า Hermes
# =============================================================================
Write-Step "Step 4: ตั้งค่า Hermes"

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
    Write-Info "สำรอง .env เดิมเป็น $backupFile"
}

# สร้าง .env ใหม่
$envContent = @"
# Hermes Agent Environment Variables
# ตั้งค่าโดย quick-install.ps1 เมื่อ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# LiteLLM Proxy (Course 0)
LITELLM_API_KEY=<your-api-key-here>

# OpenRouter API Key (Free Tier)
OPENROUTER_API_KEY=$OpenRouterKey

# Telegram Bot Token
TELEGRAM_BOT_TOKEN=$TelegramToken
"@

$envContent | Set-Content $envFile -Encoding UTF8
Write-Ok "สร้าง .env พร้อม API keys"

# สร้าง config.yaml
$configFile = Join-Path $hermesDir "config.yaml"
if (Test-Path $configFile) {
    $backupConfig = "$configFile.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $configFile $backupConfig
    Write-Info "สำรอง config.yaml เดิมแล้ว"
}

$configContent = @"
# Hermes Agent Configuration
# ตั้งค่าโดย quick-install.ps1 เมื่อ $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

# Model Configuration (ใช้ LiteLLM Proxy)
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
  mode: off  # ไม่ต้อง approve commands (YOLO mode)

# Telegram Gateway
telegram:
  reactions: true  # ตอบโต้ได้ทันที

security:
  redact_secrets: false  # แสดง credentials ไม่ต้องซ่อน

privacy:
  redact_pii: false  # แสดงข้อมูลส่วนตัว (email, phone) ไม่ต้องซ่อน
"@

$configContent | Set-Content $configFile -Encoding UTF8
Write-Ok "สร้าง config.yaml (ใช้ LiteLLM Proxy + qwen3.7-plus)"
Write-Ok "ตั้งค่า: approvals=off, reactions=true, redact_secrets=false, redact_pii=false"
Write-Ok "Dashboard: http://localhost:9119"

# =============================================================================
# Step 5: ตั้งค่า Auto-Start หลังรีสตาร์ท (Windows Task Scheduler)
# =============================================================================
Write-Step "Step 5: ตั้งค่า Auto-Start หลังรีสตาร์ท"

# หา hermes executable
$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
$hermesBin = $null
if ($hermesCmd) {
    $hermesBin = $hermesCmd.Source
} elseif (Test-Path "$NpmGlobal\hermes.cmd") {
    $hermesBin = "$NpmGlobal\hermes.cmd"
}

if (-not $hermesBin) {
    Write-Warn "ไม่พบ hermes executable — ข้ามการตั้งค่า auto-start"
} else {
    Write-Info "พบ hermes ที่: $hermesBin"
    
    # สร้าง startup scripts
    $startupDir = Join-Path $env:USERPROFILE ".hermes\startup"
    if (-not (Test-Path $startupDir)) {
        New-Item -ItemType Directory -Path $startupDir -Force | Out-Null
    }
    
    # สร้าง batch file สำหรับ gateway
    $gatewayBat = Join-Path $startupDir "hermes-gateway.bat"
    $gatewayContent = @"
@echo off
set PATH=$NpmGlobal;$env:Path
"$hermesBin" gateway start
"@
    $gatewayContent | Set-Content $gatewayBat -Encoding ASCII
    
    # สร้าง batch file สำหรับ dashboard
    $dashboardBat = Join-Path $startupDir "hermes-dashboard.bat"
    $dashboardContent = @"
@echo off
set PATH=$NpmGlobal;$env:Path
"$hermesBin" dashboard start
"@
    $dashboardContent | Set-Content $dashboardBat -Encoding ASCII
    
    # สร้าง Windows Task Scheduler tasks
    try {
        # ลบ tasks เก่าถ้ามี
        schtasks /Delete /TN "HermesGateway" /F 2>$null
        schtasks /Delete /TN "HermesDashboard" /F 2>$null
        
        # สร้าง task สำหรับ gateway (run at logon)
        $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$gatewayBat`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Days 0)
        $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
        
        Register-ScheduledTask -TaskName "HermesGateway" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description "Hermes Agent Telegram Gateway" -Force | Out-Null
        
        # สร้าง task สำหรับ dashboard (run at logon)
        $action2 = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$dashboardBat`""
        $trigger2 = New-ScheduledTaskTrigger -AtLogOn
        
        Register-ScheduledTask -TaskName "HermesDashboard" -Action $action2 -Trigger $trigger2 -Settings $settings -Principal $principal -Description "Hermes Agent Web Dashboard" -Force | Out-Null
        
        Write-Ok "สร้าง Windows Task Scheduler tasks"
        Write-Ok "  - HermesGateway (Telegram)"
        Write-Ok "  - HermesDashboard (Dashboard)"
        Write-Info "เริ่ม services ด้วย: schtasks /Run /TN `"HermesGateway`" && schtasks /Run /TN `"HermesDashboard`""
    } catch {
        Write-Warn "สร้าง Task Scheduler ไม่สำเร็จ — ใช้ Startup Folder แทน"
        
        # ใช้ Startup Folder แทน
        $startupFolder = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Startup")
        
        # สร้าง shortcut สำหรับ gateway
        $wsGateway = New-Object -ComObject WScript.Shell
        $shortcutGateway = $wsGateway.CreateShortcut("$startupFolder\HermesGateway.lnk")
        $shortcutGateway.TargetPath = "cmd.exe"
        $shortcutGateway.Arguments = "/c `"$gatewayBat`""
        $shortcutGateway.WindowStyle = 7  # Minimized
        $shortcutGateway.Save()
        
        # สร้าง shortcut สำหรับ dashboard
        $shortcutDashboard = $wsGateway.CreateShortcut("$startupFolder\HermesDashboard.lnk")
        $shortcutDashboard.TargetPath = "cmd.exe"
        $shortcutDashboard.Arguments = "/c `"$dashboardBat`""
        $shortcutDashboard.WindowStyle = 7  # Minimized
        $shortcutDashboard.Save()
        
        Write-Ok "สร้าง Startup Folder shortcuts"
        Write-Ok "  - HermesGateway.lnk (Telegram)"
        Write-Ok "  - HermesDashboard.lnk (Dashboard)"
    }
}

# =============================================================================
# Step 6: ตรวจสอบการติดตั้ง
# =============================================================================
Write-Step "Step 6: ตรวจสอบการติดตั้ง"

$hermesCmd = Get-Command hermes -ErrorAction SilentlyContinue
if ($hermesCmd) {
    $hermesVer = hermes --version 2>$null
    Write-Ok "hermes พร้อมใช้งาน: $hermesVer"
} else {
    Write-Warn "hermes ไม่อยู่ใน PATH"
    Write-Host ""
    Write-Host "ลองทำอย่างใดอย่างหนึ่ง:" -ForegroundColor Yellow
    Write-Host "  1. เปิด PowerShell ใหม่แล้วลองอีกครั้ง" -ForegroundColor White
    Write-Host "  2. หรือใช้ path เต็ม:" -ForegroundColor White
    Write-Host "     & `"$NpmGlobal\hermes.cmd`"" -ForegroundColor White
}

# =============================================================================
# Step 7: สรุปผล
# =============================================================================
Write-Step "สรุปผลการติดตั้ง"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                    ติดตั้งเสร็จสมบูรณ์!                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "ติดตั้งใน user-space (ไม่ต้อง Admin):" -ForegroundColor Cyan
Write-Host "  - Git → ~/.local/git/" -ForegroundColor White
Write-Host "  - Node.js v22+ → ~/.nvm/ หรือ ~/.local/node/" -ForegroundColor White
Write-Host "  - Python 3.11+ → ~/.local/python/" -ForegroundColor White
Write-Host "  - npm global → ~/.npm-global/" -ForegroundColor White
Write-Host "  - Hermes → ~/.npm-global/hermes.cmd" -ForegroundColor White
Write-Host ""
Write-Host "การตั้งค่า:" -ForegroundColor Cyan
Write-Host "  - Model: qwen3.7-plus (ผ่าน LiteLLM Proxy)" -ForegroundColor White
Write-Host "  - Dashboard: http://localhost:9119" -ForegroundColor White
if (-not [string]::IsNullOrWhiteSpace($TelegramToken)) {
    Write-Host "  - Telegram: พร้อมใช้งาน" -ForegroundColor Green
} else {
    Write-Host "  - Telegram: ยังไม่ได้ตั้ง" -ForegroundColor Yellow
}
Write-Host "  - Auto-start: หลังล็อกอิน" -ForegroundColor Green
Write-Host ""
Write-Host "คำสั่งที่ควรใช้:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  hermes                          เริ่ม Hermes CLI (สนทนา)" -ForegroundColor Yellow
Write-Host "  hermes model                    เปลี่ยน model" -ForegroundColor Yellow
Write-Host "  hermes doctor                   วินิจฉัยปัญหา" -ForegroundColor Yellow
Write-Host ""
Write-Host "เริ่ม Telegram Gateway + Dashboard:" -ForegroundColor Cyan
Write-Host "  schtasks /Run /TN `"HermesGateway`"" -ForegroundColor Yellow
Write-Host "  schtasks /Run /TN `"HermesDashboard`"" -ForegroundColor Yellow
Write-Host ""
Write-Host "ทดสอบการทำงาน:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  hermes" -ForegroundColor Yellow
Write-Host "  > สวัสดี ช่วยอะไรได้บ้าง" -ForegroundColor White
Write-Host ""

if (-not [string]::IsNullOrWhiteSpace($OpenRouterKey)) {
    Write-Host "Models ฟรีที่ใช้ได้ (ผ่าน OpenRouter):" -ForegroundColor Cyan
    Write-Host "  - google/gemini-2.5-flash        (เร็ว, ถูก)" -ForegroundColor White
    Write-Host "  - google/gemini-2.5-flash-lite   (เร็วมาก)" -ForegroundColor White
    Write-Host "  - meta-llama/llama-3.3-70b       (ฉลาด)" -ForegroundColor White
    Write-Host ""
    Write-Host "ดู models ทั้งหมด: https://openrouter.ai/models?q=free" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "พร้อมเริ่มเรียน Course 0: Hermes + AI Harness!" -ForegroundColor Green
Write-Host ""

# --- Prompt to continue ---
Read-Host "กด Enter เพื่อปิดหน้าต่างนี้"
