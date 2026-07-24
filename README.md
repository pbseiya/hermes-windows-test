# Hermes Agent Windows Installation (Course 0)

**Repository:** `pbseiya/hermes-windows-test`
**Creator:** Hermes Agent Training Team | **Updated:** 2026-07-24

This repository provides automated installation scripts, guides, and course materials for setting up the Hermes Agent on Windows.

---

## 📋 Prerequisites

**No admin rights are needed** (everything installs in the user folder). You will need the following before starting:

| Requirement | How to Obtain |
| :--- | :--- |
| **LiteLLM API Key** | Provided by instructor (Course 0) |
| **Telegram Bot Token** | Create via `@BotFather` in Telegram (Slide Module 02) |
| **Telegram Chat ID** | Search `@userinfobot` in Telegram > press `/start` > copy the number |

---

## ⚙️ Installation & Uninstallation

*   **Environment:** All installation commands must be run in **PowerShell**.
*   **Uninstall Time:** Takes ~2-3 minutes (utilizes fast `robocopy`-based deletion for all `node_modules`).

### ⚠️ CRITICAL: Antivirus Warning
**You must temporarily disable your antivirus during installation** to ensure full functionality of the Dashboard and Desktop features.
*   *If you do not disable antivirus:* It will block `npm`, causing the Dashboard and Desktop components to fail.

---

## 🚀 Post-Installation Features

| Feature | Availability / Requirements |
| :--- | :--- |
| **Telegram Gateway** | Immediately available (No AV disable needed) |
| **Dashboard** | Requires antivirus to be disabled during install |
| **Desktop** | Requires antivirus to be disabled during install |

---

## 🔑 Change API Key After Installation

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

### Method 3: Edit Config File
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```
Add or update: `LITELLM_API_KEY=your-key-here`

### After Changing the Key
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # Test
```

---

## 🛠️ Troubleshooting Guide

### 1. Dashboard / Desktop Not Working
*Cause: Antivirus blocked `npm` during installation.*
Run the following commands to attempt recovery:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm install --workspace web --no-fund --no-audit
npm run build -w web
```
Then retry:
```powershell
hermes dashboard
hermes desktop
```

### 2. Telegram Bot Not Responding
Check the Python process, restart the gateway, and review the logs:
```powershell
Get-Process -Name pythonw
hermes gateway start
type %LOCALAPPDATA%\hermes\logs\gateway.log
```

### 3. Services Not Starting After Reboot
Verify Task Scheduler tasks (primary auto-start method):
```powershell
schtasks /Query /TN "HermesGateway"
schtasks /Query /TN "HermesDashboard"
```
If missing, start manually:
```powershell
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```
**Fallback:** If Task Scheduler is restricted, check the Windows Startup folder:
*   **Startup Path:** `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`

### 4. `hermes` Command Not Recognized
*Cause: PATH not loaded or incorrect path.*
```powershell
# Open a new PowerShell window
# Or use the full path:
& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"
```

---

## 📂 Repository Files Reference

| File(s) | Description |
| :--- | :--- |
| `quick-install.ps1`, `quick-install.bat` | One-liner / double-click installation scripts |
| `quick-uninstall.ps1` | One-liner uninstallation script |
| `02-hermes-setup.html`, `02-hermes-setup.md` | Course 02 setup slides (HTML and Markdown source) |
| `INSTALLATION_GUIDE.md` | Comprehensive installation instructions |
| `TESTING_GUIDE.md` | Post-installation testing procedures |
| `ONE_LINE_COMMANDS.md` | Quick reference for one-liner commands |
