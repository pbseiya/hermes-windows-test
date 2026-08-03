# Module 02: Hermes Installation & Setup (Windows)

## 🎯 Module Objectives

After completing this module, you will be able to:

1. Install Hermes Agent on Windows (no admin rights required)
2. Configure LiteLLM API Key and Telegram Bot
3. Access the Web Dashboard
4. Change API Key after installation
5. Troubleshoot common installation issues

---

## 📋 Prerequisites

Before starting, you need:

| Item | How to Get |
|------|-----------|
| **LiteLLM API Key** | Provided by instructor |
| **Telegram Bot Token** | Create via @BotFather in Telegram |
| **Telegram Chat ID** | Get from @userinfobot in Telegram |

---

## 🚀 Step 1: Quick Install

### Option A: PowerShell (Recommended)

```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### Option B: CMD

```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```

### Option C: Double-click

1. Download `quick-install.bat` from GitHub
2. Double-click to run

---

## 📦 What Gets Installed

The script installs these components in user-space:

| Component | Purpose |
|-----------|---------|
| **Git** (portable) | Version control |
| **Node.js v22** (portable) | Dashboard & Desktop |
| **Python 3.11** (embeddable) | Hermes runtime |
| **uv** | Python package manager |
| **Hermes Agent** | AI assistant + Gateway + Dashboard |
| **Antigravity CLI (agy)** | Repair tool |

**All installed in:** `%LOCALAPPDATA%\hermes\` (no admin required)

---

## ⚠️ Important: Antivirus

**Temporarily disable antivirus during installation** for Dashboard and Desktop to work properly.

If you don't disable it:
- ✅ Hermes CLI + Telegram will work
- ❌ Dashboard + Desktop will need manual fix (see Troubleshooting)

---

## 🔑 Step 2: Initial Configuration

During installation, you'll be prompted for:

### 1. LiteLLM API Key
- Provided by instructor
- Press Enter to skip (can add later)

### 2. Telegram Bot Token
- Create bot via @BotFather
- Send `/newbot` command
- Copy the token

### 3. Telegram Chat ID
- Get from @userinfobot
- Restricts bot access to you only

**Can skip all prompts** and configure later (see Step 6).

---

## 📂 Step 3: Verify Installation

Open a **new PowerShell window** and run:

```powershell
# Check version
hermes --version

# Start chat
hermes

# Test a message
hermes chat -q "สวัสดี"
```

If `hermes` command not found, try:
```powershell
& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"
```

---

## 🌐 Step 4: Access Dashboard

```powershell
hermes dashboard
```

Opens at: `http://localhost:9119`

Features:
- Session history
- Cron jobs management
- Tools & skills
- Configuration viewer
- Usage statistics

---

## 🤖 Step 5: Telegram Integration

### Start Gateway

```powershell
hermes gateway start
```

### Auto-start Behavior

Gateway starts automatically after reboot via Windows Task Scheduler:
- `HermesGateway` task (30s delay)
- `HermesDashboard` task (60s delay)

### Manual Start (if needed)

```powershell
schtasks /Run /TN "HermesGateway"
```

---

## 🔑 Step 6: Change API Key After Installation

If you skipped the API key during installation or need to change it:

### Method 1: Interactive Wizard (Recommended)

```powershell
hermes model
```

Follow prompts to select provider and enter API key.

### Method 2: Direct Command

```powershell
hermes config set model.api_key "your-api-key-here"
```

### Method 3: Edit Config File

```powershell
notepad %LOCALAPPDATA%\hermes\.env
```

Add or modify:
```
LITELLM_API_KEY=your-api-key-here
```

### Apply Changes

```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

## 🧠 Step 7: Model Configuration

### Default Setup

- **Model:** `qwen3.7-plus`
- **Provider:** LiteLLM Proxy
- **Context Length:** 1,000,000 tokens
- **Base URL:** `https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1`

### Switch Models (Temporary)

```text
/model anthropic/claude-sonnet-4
/model openai/gpt-4o
```

### Model Comparison

| Model | Best For | Cost |
|-------|----------|------|
| **qwen3.7-plus** | General tasks | Free (Course 0) |
| Claude Sonnet 4 | Balanced performance | Paid |
| GPT-4o | Fast responses | Paid |
| Claude Opus 4 | Complex reasoning | Paid |

---

## 🔒 Step 8: Security Settings

Default configuration (Course 0):

```yaml
approvals:
  mode: off              # No command approval needed
telegram:
  reactions: true        # Auto-react to messages
security:
  redact_secrets: false  # Don't hide secrets in logs
privacy:
  redact_pii: false      # Don't hide personal info
```

**Note:** These settings are relaxed for training. Adjust for production use.

---

## 🐛 Troubleshooting

### Problem 1: `hermes` Command Not Found

**Solution:**
```powershell
# Open new PowerShell window
# Or use full path:
& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"
```

### Problem 2: Dashboard Not Working

**Cause:** Antivirus blocked npm during installation

**Solution:**
1. Disable antivirus temporarily
2. Run:
```powershell
cd %LOCALAPPDATA%\hermes\hermes-agent
npm run build -w web
```
3. Re-enable antivirus
4. Restart: `hermes dashboard`

### Problem 3: Telegram Bot Not Responding

**Check:**
```powershell
# Is gateway running?
Get-Process -Name pythonw

# View logs
type %LOCALAPPDATA%\hermes\logs\gateway.log

# Restart gateway
hermes gateway restart
```

### Problem 4: Services Not Starting After Reboot

**Check Task Scheduler:**
```powershell
schtasks /Query /TN "HermesGateway"
schtasks /Query /TN "HermesDashboard"
```

**Manual start:**
```powershell
schtasks /Run /TN "HermesGateway"
```

### Problem 5: API Key Issues

**Solution:**
```powershell
# Check current config
hermes config

# Update API key
hermes config set model.api_key "your-new-key"

# Restart
hermes gateway restart
```

---

## 📚 Additional Resources

| File | Purpose |
|------|---------|
| `README.md` | Quick start guide |
| `INSTALLATION_GUIDE.md` | Detailed installation steps |
| `TESTING_GUIDE.md` | Post-install checklist |
| `ONE_LINE_COMMANDS.md` | Command reference |

---

## 📞 Support

If you encounter issues:
1. Check `TESTING_GUIDE.md` for troubleshooting
2. Contact instructor via course channel

---

**Module completed:** You can now install, configure, and troubleshoot Hermes Agent on Windows!
