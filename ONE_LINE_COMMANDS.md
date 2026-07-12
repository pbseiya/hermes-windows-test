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

1. ✅ Check and install Node.js v22+ (user-space, no admin)
2. ✅ Check and install Python 3.11+ (user-space, no admin)
3. ✅ Install uv (Python package manager)
4. ✅ Install Hermes Agent via uv
5. ✅ Install Antigravity CLI (agy) for Gemini free tier
6. ✅ Ask for LiteLLM API Key and Telegram Bot Token
7. ✅ Configure Hermes (config.yaml, .env)
8. ✅ Setup auto-start with Windows Task Scheduler

---

## After Installation

```powershell
# Start Hermes CLI
hermes

# Start Telegram Gateway
schtasks /Run /TN "HermesGateway"

# Start Dashboard
schtasks /Run /TN "HermesDashboard"
```

Dashboard: http://localhost:9119
