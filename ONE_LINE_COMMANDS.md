# One-Line Install Commands

## PowerShell (Recommended)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

## Alternative: Download and Run
```powershell
$f="$env:TEMP\hermes-install.ps1"; irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 -OutFile $f; powershell -ExecutionPolicy Bypass -File $f; Remove-Item $f
```

## CMD (Command Prompt)
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```

---

## What the Script Does

1. ✅ Check and install **Git** Portable v2.47.1+ (user-space, no admin)
2. ✅ Check and install **Node.js** v22.14.0+ (user-space, no admin)
3. ✅ Check and install **Python** 3.11.9+ (user-space, no admin)
4. ✅ Install **uv** (Python package manager)
5. ✅ Install **Hermes Agent** via uv + npm build (Dashboard, Desktop, TUI)
6. ✅ Install **Antigravity CLI (agy)** for Gemini free tier
7. ✅ Ask for **LiteLLM API Key**, **Telegram Bot Token**, and **Telegram Chat ID**
8. ✅ Configure Hermes (`.env`, `config.yaml`) at `%LOCALAPPDATA%\hermes\`
9. ✅ Setup auto-start with **Windows Task Scheduler** (Gateway 30s, Dashboard 60s)
10. ✅ Start Telegram Gateway immediately

---

## After Installation

### Core Commands
```powershell
hermes              # Start CLI chat
hermes doctor       # Diagnose problems
hermes model        # Change model/provider
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
- **LiteLLM Proxy:** `https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1`
- **Dashboard:** `http://localhost:9119`
- **Security:** `approvals: off`, `redact_secrets: false`, `redact_pii: false`

---

## 🔑 Change API Key After Installation

If you skipped the API key prompts during installation or need to update your key:

### Method 1: Interactive Wizard (Recommended)
```powershell
hermes model
```

### Method 2: Direct Command
```powershell
hermes config set model.api_key "your-api-key-here"
```

### Method 3: Edit .env File
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```

### ⚠️ Restart After Change
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

## Uninstall

```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
```

Takes ~2-3 minutes (uses fast robocopy-based deletion for all `node_modules`)
