# Module 2: Hermes Installation & Setup Summary (Windows)

## 🎯 Learning Objectives
By the end of this module, you will be able to:
* Run the Quick Install Script without admin rights (user-space installation).
* Create and configure a Telegram Bot Token and Chat ID.
* Understand LiteLLM Proxy integration with the `qwen3.7-plus` model.
* Access the local Dashboard (`http://localhost:9119`).
* Configure auto-start services post-reboot.
* Change API key after installation if needed.

---

## 🤖 Step 1: Create Telegram Bot Token (Prerequisite)
*Do this **before** running the Quick Install Script.*

1. Open Telegram and search for `@BotFather`.
2. Send `/newbot`.
3. Set a name (e.g., "My Hermes Bot") and a username (must end in `bot`, e.g., `my_hermes_bot`).
4. **Copy the generated Bot Token** (Format: `1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ`).

### Get Your Telegram Chat ID
*This restricts bot access to only you.*

1. Open Telegram and search for `@userinfobot`.
2. Send `/start`.
3. **Copy the numeric ID** (e.g., `123456789`).

---

## 🚀 Step 2: Quick Install Script
Installs Git, Node.js v22+, Python 3.11+, uv, Hermes Agent, and Antigravity CLI automatically in **user-space** (no admin rights required).

**Windows (PowerShell One-Liner):**
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

**Alternative: CMD**
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```

**Alternative: Double-Click**
1. Download `quick-install.bat` from the repository
2. Double-click to run

> **Note:** The script will prompt for:
> - **LiteLLM API Key** (provided by instructor)
> - **Telegram Bot Token** (from Step 1)
> - **Telegram Chat ID** (from Step 1)
>
> You can press Enter to skip any prompt and add keys later.

### ⚠️ Antivirus Warning
**Temporarily disable antivirus during installation** for full Dashboard and Desktop functionality. If you don't, `npm` will be blocked and these features will fail (see Troubleshooting).

---

## 🔧 Step 3: Antigravity CLI (`agy`)
*Installed automatically by the script. A free CLI tool using your existing Google Account for Gemini access. Useful for fixing Hermes without password prompts.*

**Post-install:** Run `agy` to log in via your browser.

---

## 📂 Step 4: User-Space Paths & PATH Configuration
The script automatically configures your PATH. **Open a new PowerShell window** after installation.

| Component | Windows Path |
| :--- | :--- |
| **Git** | `%USERPROFILE%\.local\git\` |
| **Node.js** | `%USERPROFILE%\.local\node\` |
| **Python** | `%USERPROFILE%\.local\python\` |
| **uv** | `%USERPROFILE%\.local\bin\` |
| **Hermes CLI** | `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe` |
| **Antigravity** | `%LOCALAPPDATA%\agy\bin\` |
| **Config Files** | `%LOCALAPPDATA%\hermes\.env`, `%LOCALAPPDATA%\hermes\config.yaml` |

---

## 🧠 Step 5: LiteLLM & Model Configuration
Course 0 uses **LiteLLM Proxy** with the `qwen3.7-plus` model (1,000,000 token context).

**Default Config (`%LOCALAPPDATA%\hermes\config.yaml`):**
```yaml
model:
  provider: custom:litellm
  default: qwen3.7-plus
  base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
  context_length: 1000000

dashboard:
  enabled: true
  port: 9119

approvals:
  mode: off

telegram:
  reactions: true
```

### Model Switching & Recommendations
Switch models on-the-fly in a session without restarting:
```text
/model anthropic/claude-sonnet-4
/model openai/gpt-4o
```

| Model | Price/1M Tokens | Best For |
| :--- | :--- | :--- |
| **qwen3.7-plus** | **Free (LiteLLM)** | **Default for all tasks** |
| Claude Sonnet 4 | $3 / $15 | General tasks |
| GPT-4o | $5 / $15 | Speed & intelligence |
| Claude Opus 4 | $15 / $75 | Complex reasoning |
| Llama 3 | Free | Testing |

---

## 🔑 Step 6: Change API Key After Installation

If you skipped the API key prompts during installation or need to update your key:

### Method 1: Interactive Wizard (Recommended)
```powershell
hermes model
```
Follow the prompts to select provider and enter your API key.

### Method 2: Direct Command
```powershell
hermes config set model.api_key "your-api-key-here"
```

### Method 3: Edit .env File
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```
Add or update: `LITELLM_API_KEY=your-key-here`

### ⚠️ Restart After Change
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

## 🌐 Step 7: Dashboard, Telegram & Auto-Start

### Web Dashboard
Access via `http://localhost:9119` to view session history, cron jobs, tools, and stats.
```powershell
hermes dashboard
```

### Telegram Gateway
```powershell
hermes gateway start
```

### Auto-Start Configuration
Services are configured to start automatically on login via **Windows Task Scheduler**:
- `HermesGateway` (30s delay after login)
- `HermesDashboard` (60s delay after login)

**Manual start (if auto-start failed):**
```powershell
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

---

## 🔒 Security & Permissions (Course 0 Defaults)
*Configured automatically for ease of use. Change for production.*
```yaml
approvals:
  mode: off          # YOLO mode: no command approvals needed
telegram:
  reactions: true    # Immediate Telegram responses
security:
  redact_secrets: false
privacy:
  redact_pii: false
```

---

## 🐛 Troubleshooting Guide

### 1. `hermes: command not found`
**Cause:** PATH not loaded.
**Fix:** Open a new PowerShell window, or use the full path:
```powershell
& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"
```

### 2. Dashboard / Desktop Not Working
**Cause:** Antivirus blocked `npm` during installation.
**Fix:**
1. Temporarily disable antivirus real-time protection
2. Run the following commands:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm install --workspace web --no-fund --no-audit
npm run build -w web
```
3. Re-enable antivirus
4. Run `hermes dashboard` or `hermes desktop`

### 3. Telegram bot not responding
**Fix:** Check service status and restart the gateway.
```powershell
# Check if running
Get-Process -Name pythonw

# Restart
hermes gateway restart

# Check logs
type $env:LOCALAPPDATA\hermes\logs\gateway.log
```

### 4. Services not starting after reboot
**Fix:** Check Task Scheduler and start manually if needed.
```powershell
# Check tasks
schtasks /Query /TN "HermesGateway"
schtasks /Query /TN "HermesDashboard"

# Start manually
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

### 5. `API key invalid`
**Fix:** Check `%LOCALAPPDATA%\hermes\.env` to ensure `LITELLM_API_KEY=` is present.
See **Step 6: Change API Key After Installation** above.

---

## 📚 Additional Resources

- **README.md** — Quick start guide
- **INSTALLATION_GUIDE.md** — Detailed installation instructions
- **TESTING_GUIDE.md** — Post-installation testing checklist
- **ONE_LINE_COMMANDS.md** — Quick reference for commands

---

**Created by:** Hermes Agent Training Team
**Updated:** 2026-07-24
