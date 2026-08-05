# 📚 Installation Guide: Hermes Agent (Course 0)

**Version:** 1.0.0 | **Updated:** 2026-08-05 | **Platform:** Windows Only
**Total Time:** 10-20 minutes | **Admin Rights:** Not Required

---

## 🎯 Overview

The installation is a fully automated **11-step script**. It requires **no admin privileges** (installs entirely in user-space). Users only need to run the script once and answer prompts when asked.

**New in v1.0.0:** Auto-query 20 models from LiteLLM proxy, full UI support (Dashboard, Desktop, TUI).

---

## ⚙️ The 11-Step Installation Process

| Step | Action | Details & Time |
| :--- | :--- | :--- |
| **1. Prerequisites** | Check environment | PowerShell 5.1+, Internet connection. *(30s)* |
| **2. Install Git** | Portable Git v2.47.1+ | Downloads to `~/.local/git/` if missing. *(1-2 mins)* |
| **3. Install Node.js** | v22.14.0+ portable | Downloads to `~/.local/node/` if missing. *(1-2 mins)* |
| **4. Install Python** | 3.11.9 embeddable | Downloads to `~/.local/python/` if missing. *(1-2 mins)* |
| **5. Install uv** | Python package manager | Installed via `irm https://astral.sh/uv/install.ps1 | iex`. *(30s)* |
| **6. Install Hermes Agent** | Main AI CLI + UI | Cloned to `%LOCALAPPDATA%\hermes\hermes-agent`, installed via `uv pip install -e '.[all]'`, npm dependencies built. *(5-15 mins)* |
| **7. Install Antigravity CLI** | Repair tool | `agy` (Gemini CLI). Requires initial Google login. *(30s-1m)* |
| **8. Prompt for Credentials** | Ask user for keys | **LiteLLM API Key**, **Telegram Bot Token**, **Telegram Chat ID**. *Can press Enter to skip.* **Auto-queries 20 models after API key entry.** *(2-5 mins)* |
| **9. Write Configuration** | Auto-write config files | Creates `%LOCALAPPDATA%\hermes\.env` and `config.yaml` with all 20 models. Auto-backs up existing files. *(5s)* |
| **10. Setup Auto-Start** | Configure boot services | Creates Windows Task Scheduler tasks: `HermesGateway` (30s delay), `HermesDashboard` (60s delay). Falls back to Startup Folder if Task Scheduler fails. *(2s)* |
| **11. Start Gateway** | Launch Telegram Gateway | Gateway starts immediately after installation. *(2s)* |

---

## 🚀 Installation Commands

### Method 1: PowerShell One-Liner (Recommended)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```
**Note:** Requires PowerShell execution policy to allow remote scripts. If blocked, use Method 2.

---

### Method 2: Download then Run (Antivirus-friendly)
```powershell
# Step 1: Download script
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 -OutFile "$env:TEMP\install.ps1"

# Step 2: Run downloaded script
powershell -ExecutionPolicy Bypass -File "$env:TEMP\install.ps1"
```
**Use this when:**
- `irm | iex` is blocked by execution policy
- Antivirus blocks inline script execution
- Corporate network restricts remote script execution

---

### Method 3: CMD (Command Prompt)
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```

---

### Method 4: Double-Click
1. Download `quick-install.bat` from the repository
2. Double-click to run

> **Fix for blocked scripts:** If you get an execution policy error, open PowerShell and run:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

---

## 📂 Installation Paths

All tools are installed in user-space. The script automatically updates your `PATH`.

| Component | Installation Path |
|---|---|
| **Git** | `%USERPROFILE%\.local\git\` |
| **Node.js** | `%USERPROFILE%\.local\node\` |
| **Python** | `%USERPROFILE%\.local\python\` |
| **uv** | `%USERPROFILE%\.local\bin\` |
| **Hermes Agent** | `%LOCALAPPDATA%\hermes\hermes-agent\` |
| **Hermes CLI** | `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe` |
| **Antigravity CLI** | `%LOCALAPPDATA%\agy\bin\` |
| **Config Files** | `%LOCALAPPDATA%\hermes\.env`, `%LOCALAPPDATA%\hermes\config.yaml` |
| **Logs** | `%LOCALAPPDATA%\hermes\logs\` |

**After installation:** Open a **new PowerShell window** for PATH changes to take effect.

---

## ⚙️ Configuration Details

The installer automatically writes to `%LOCALAPPDATA%\hermes\`:

### `.env` File
```env
LITELLM_API_KEY=<your-key>
TELEGRAM_BOT_TOKEN=<your-token>
TELEGRAM_ALLOWED_USERS=<your-chat-id>
HERMES_PYTHON=<path-to-venv-python>
```

### `config.yaml` File
```yaml
model:
  provider: litellm
  default: qwen3.7-plus
  base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
  api_key: <your-key>

providers:
  litellm:
    api_key: <your-key>
    base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
    default_model: qwen3.7-plus
    models:
      qwen3.7-plus:
        context_length: 1000000
      qwen3.6-plus:
        context_length: 1000000
      # ... 18 more models auto-queried from proxy

dashboard:
  enabled: true
  port: 9119

approvals:
  mode: off

security:
  redact_secrets: false

privacy:
  redact_pii: false

telegram:
  reactions: true
```

---

## ✅ Post-Installation Checklist

- [ ] `hermes --version` executes successfully
- [ ] `hermes` opens the CLI and responds to "สวัสดี"
- [ ] `hermes doctor` shows no errors
- [ ] `hermes model` displays 20 available models
- [ ] `hermes --tui` opens the TUI interface
- [ ] Dashboard is accessible at `http://localhost:9119`
- [ ] `hermes desktop` opens the Electron app
- [ ] Telegram bot replies (if token was provided)
- [ ] Telegram `/model` shows 20 models
- [ ] `agy` runs and prompts for Google login
- [ ] All commands work from any directory (PATH verified)
- [ ] Gateway auto-starts after reboot
- [ ] Dashboard auto-starts after reboot

---

## 🔑 Adding API Key After Installation

If you skipped the API key prompts during installation:

### Method 1: Interactive Wizard (Recommended)
```powershell
hermes model
```
Follow the prompts to select provider and enter your API key.

### Method 2: Direct Command
```powershell
hermes config set model.api_key "your-api-key-here"
```

### Method 3: Edit Config File
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```
Add or update: `LITELLM_API_KEY=your-key-here`

### After Adding the Key
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

## 🌐 PATH Configuration

All tools are added to the User PATH automatically. **You must open a new PowerShell window** for changes to take effect.

**Paths added:**
- `%USERPROFILE%\.local\git\bin`
- `%USERPROFILE%\.local\node`
- `%USERPROFILE%\.local\python`
- `%USERPROFILE%\.local\bin`
- `%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts`
- `%LOCALAPPDATA%\agy\bin`

---

## 🐛 Troubleshooting Quick Reference

| Error / Issue | Cause & Solution |
| :--- | :--- |
| **`hermes: command not found`** | PATH not loaded. **Fix:** Open a new PowerShell window, or use full path: `& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"` |
| **`Execution Policy`** | PowerShell blocks scripts. **Fix:** `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| **`agy: command not found`** | PATH not loaded or not logged in. **Fix:** Open new PowerShell, then run `agy` to login with Google. |
| **Dashboard/Desktop not working** | Missing web build. **Fix:** Run `npm install --no-fund --no-audit && npm run build -w web` in `%LOCALAPPDATA%\hermes\hermes-agent` |
| **Telegram bot not responding** | Gateway not running. **Fix:** `hermes gateway start` or `schtasks /Run /TN "HermesGateway"` |
| **Services not starting after reboot** | Task Scheduler tasks missing. **Fix:** `schtasks /Run /TN "HermesGateway"` and `schtasks /Run /TN "HermesDashboard"` |
| **Download fails** | Internet/Proxy issue. **Fix:** Check connection or configure corporate proxy. |
| **Desktop shows errors on first launch** | Normal warnings (registry, WSL, session 404s). Harmless. Only investigate if window fails to open. |

---

## 📞 Support

If issues persist:
1. Read `TESTING_GUIDE.md` for detailed troubleshooting steps.
2. Check [GitHub Issues](https://github.com/pbseiya/hermes-windows-test/issues)
3. Contact your instructor through the channel specified in Course 0.
