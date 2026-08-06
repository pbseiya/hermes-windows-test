# One-Line Install Commands

## Method 1: PowerShell One-Liner (Quick)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```
**Suitable for:** Personal machines, testing environments
**Note:** Requires PowerShell execution policy to allow remote scripts. If blocked, use Method 2.

---

## Method 2: Download then Run (Corporate-Recommended)
```powershell
# Step 1: Download script to TEMP folder
$f = "$env:TEMP\hermes-install.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1' -OutFile $f -UseBasicParsing

# Step 2: Review script (optional, for audit)
notepad $f

# Step 3: Run with ExecutionPolicy bypass
powershell -ExecutionPolicy Bypass -File $f

# Step 4: Clean up
Remove-Item $f
```
**Suitable for:** Corporate environments, audit compliance, antivirus restrictions

**Why Method 2 for Corporate:**
- ✅ Download first → IT can review script before execution
- ✅ `-UseBasicParsing` → Compatible with older PowerShell 5.1
- ✅ `-ExecutionPolicy Bypass` → Avoids execution policy blocks
- ✅ Local file → Antivirus less likely to block
- ✅ Audit trail → Log shows which script version was run

**Use this when:**
- `irm | iex` is blocked by execution policy
- Antivirus blocks inline script execution
- Corporate network restricts remote script execution
- IT requires script review before execution

---

## Method 3: Cache-Busting (If CDN returns old version)
```powershell
$f = "$env:TEMP\hermes-install.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1?t=20260806' -OutFile $f -UseBasicParsing
powershell -ExecutionPolicy Bypass -File $f
Remove-Item $f
```
**Use when:** GitHub CDN caches old script version (add current date as timestamp)

---

## Method 4: CMD (Command Prompt)
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```
**Suitable for:** Users who prefer CMD over PowerShell

---

## What the Script Does

1. ✅ Check and install **Git** Portable v2.47.1+ (user-space, no admin)
2. ✅ Check and install **Node.js** v22.14.0+ (user-space, no admin)
3. ✅ Check and install **Python** 3.11.9+ (user-space, no admin)
4. ✅ Install **uv** (Python package manager)
5. ✅ Install **Hermes Agent** via uv + npm build (Dashboard, Desktop, TUI)
6. ✅ Install **Antigravity CLI (agy)** for Gemini free tier
7. ✅ Ask for **LiteLLM API Key**, **Telegram Bot Token**, and **Telegram Chat ID**
8. ✅ **Auto-query 20 models** from LiteLLM proxy after API key entry
9. ✅ Configure Hermes (`.env`, `config.yaml`) at `%LOCALAPPDATA%\hermes\` with all 20 models
10. ✅ Setup auto-start with **Windows Task Scheduler** (Gateway 30s, Dashboard 60s)
11. ✅ Start Telegram Gateway immediately

---

## After Installation

### Core Commands
```powershell
hermes              # Start CLI chat
hermes --tui        # Start TUI (Terminal UI)
hermes doctor       # Diagnose problems
hermes model        # Change model (20 available)
hermes dashboard    # Open web dashboard (http://localhost:9119)
hermes desktop      # Launch Electron desktop app
```

### Service Management
```powershell
# Manual start (if auto-start failed)
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"

# Or use hermes CLI
hermes gateway start
hermes gateway stop
hermes gateway restart
```

### Config File Locations
```
%LOCALAPPDATA%\hermes\.env              # API keys, Telegram tokens
%LOCALAPPDATA%\hermes\config.yaml       # Model, dashboard, security settings
%LOCALAPPDATA%\hermes\logs\             # Gateway and error logs
```

### Default Configuration
- **Model:** `qwen3.7-plus` (1,000,000 token context)
- **Provider:** LiteLLM Proxy
- **Base URL:** `https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1`
- **Dashboard:** `http://localhost:9119`
- **Security:** `approvals: off`, `redact_secrets: false`, `redact_pii: false`

### Available Models (20 total)
```
qwen3.7-plus, qwen3.6-plus, qwen3.5-plus
glm-5, glm-4.7
kimi-k2.5, MiniMax-M2.5
qwen3-coder-plus, qwen3-coder-next, qwen3-max-2026-01-23
anthropic/qwen3.7-plus, anthropic/qwen3.6-plus, anthropic/qwen3.5-plus
anthropic/glm-5, anthropic/glm-4.7, anthropic/kimi-k2.5
anthropic/MiniMax-M2.5, anthropic/qwen3-coder-plus
anthropic/qwen3-coder-next, anthropic/qwen3-max-2026-01-23
```

---

## 🔑 Change API Key After Installation

If you skipped the API key prompts during installation or need to update your key:

### Method 1: Interactive Wizard (Recommended)
```powershell
hermes model
```

### Method 2: Direct Command (Recommended)
```powershell
# Set API key (saved to .env automatically)
hermes config set LITELLM_API_KEY "sk-jCHHiVn5dx41A3MusmR4QQ"

# Set model (saved to config.yaml automatically)
hermes config set model litellm/qwen3.7-plus
```

### Method 3: Edit .env File Directly
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```

### ⚠️ Restart After Change
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

##  Telegram Bot Commands

After setup, use these commands in Telegram:

```text
/model          # Switch between 20 models (inline button menu)
/help           # Show available commands
/sessions       # List active sessions
```

---

## Uninstall

### Method 1: Download then Run (Corporate-Recommended)
```powershell
# Step 1: Download uninstall script
$f = "$env:TEMP\hermes-uninstall.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1' -OutFile $f -UseBasicParsing

# Step 2: Run with ExecutionPolicy bypass
powershell -ExecutionPolicy Bypass -File $f

# Step 3: Clean up
Remove-Item $f
```
**Suitable for:** Corporate environments, audit compliance, antivirus restrictions

**Why Method 1 for Corporate:**
- ✅ Download first → IT can review script before execution
- ✅ `-UseBasicParsing` → Compatible with older PowerShell 5.1
- ✅ `-ExecutionPolicy Bypass` → Avoids execution policy blocks
- ✅ Local file → Antivirus less likely to block

---

### Method 2: PowerShell One-Liner (Quick)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
```
**Suitable for:** Personal machines, testing environments
**Note:** May be blocked by execution policy or antivirus in corporate environments.

---

**Uninstall Time:** ~2-3 minutes (uses parallel fast deletion for all `node_modules`)

**What Gets Removed:**
- ✅ Hermes Agent + all data
- ✅ Node.js, Git, Python (portable)
- ✅ uv, agy
- ✅ Scheduled tasks + startup shortcuts
- ✅ PATH entries
- ✅ npm cache

**Note:** Config files in `%LOCALAPPDATA%\hermes\` are preserved (sessions, logs, .env, config.yaml). Delete manually if needed.

### If Log is Too Long to Scroll

If you cannot scroll up to see the full log:

**Option 1: Increase Console Buffer Size**
```powershell
$host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size 120,9999
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
```

**Option 2: Redirect Output to File**
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex | Tee-Object -FilePath uninstall.log
```

Then view the log:
```powershell
notepad uninstall.log
```
