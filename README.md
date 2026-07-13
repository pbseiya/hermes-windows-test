# Hermes Agent Quick Install

Install guide for Hermes Agent - Course 0

---

## One-liner Commands

### Install
Open **PowerShell** and run:
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### Uninstall
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
```

---

## What you need before installing

| Item | How to get |
|------|-----------|
| **LiteLLM API Key** | From instructor (Course 0) |
| **Telegram Bot Token** | Create from @BotFather in Telegram (see Slide Module 02) |
| **Telegram Chat ID** | Search @userinfobot in Telegram > press /start > copy the number |

> No admin rights needed - everything installs in user folder

---

## What the script installs automatically

- Git Portable v2.47+
- Node.js v22+ (portable)
- Python 3.11+ (embeddable)
- uv (Python package manager)
- Hermes Agent v0.18+ (Dashboard, Desktop, TUI)
- Antigravity CLI (agy) - for fixing hermes
- Auto-start after login

---

## After installation

```powershell
hermes                          # Chat with Hermes (TUI)
hermes dashboard                # Open Web Dashboard
hermes desktop                  # Open Desktop App (Electron)
hermes model                    # Change model
hermes doctor                   # Diagnose problems
```

**Dashboard:** http://localhost:9119

**Start Telegram Gateway + Dashboard after login:**
```powershell
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

---

## FAQ

### Q: Do I need admin rights?
**A:** No. Everything installs in your user folder.

### Q: How long does it take?
**A:** 10-20 minutes depending on internet speed and antivirus.

### Q: Do I need to restart?
**A:** No. But open a new PowerShell window after installation.

### Q: Dashboard/Desktop does not work?
**A:** Run these commands to fix:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm install --workspace web --no-fund --no-audit
npm run build -w web
```
If still broken, uninstall and reinstall:
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### Q: Telegram bot not responding?
**A:** Check: 1) Bot Token is correct  2) Chat ID is correct (get from @userinfobot)  3) Run `hermes gateway start`

### Q: How to use agy to fix hermes?
**A:** Run `agy`, login with Google Account (free), then ask agy to fix hermes.

---

## Files in this Repository

| File | Description |
|------|------------|
| `quick-install.ps1` | Install script (one-liner) |
| `quick-uninstall.ps1` | Uninstall script (one-liner) |
| `quick-install.bat` | Batch file (double-click) |
| `02-hermes-setup.html` | Slides (open in browser) |
| `02-hermes-setup.md` | Slides (Markdown source) |
| `INSTALLATION_GUIDE.md` | Full installation guide |
| `TESTING_GUIDE.md` | Post-install testing guide |

---

**Created by:** Hermes Agent Training Team
**Updated:** 2026-07-13
