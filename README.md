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

## Important: Antivirus

**For full functionality (Dashboard + Desktop), temporarily disable antivirus during installation:**

1. Open Windows Security > Virus & threat protection > Manage settings
2. Turn off **Real-time protection**
3. Run the install script
4. Turn on Real-time protection after installation

**If you don't disable antivirus:**
- ✅ TUI + Telegram will work immediately
- ❌ Dashboard + Desktop need manual fix (see Troubleshooting)

---

## What the script installs automatically

- Git Portable v2.47+
- Node.js v22+ (portable)
- Python 3.11+ (embeddable)
- uv (Python package manager)
- Hermes Agent v0.18+ (Dashboard, Desktop, TUI)
- Antigravity CLI (agy) - for fixing hermes
- Auto-start after login (Telegram Gateway + Dashboard)

---

## After installation

### Immediately available (no antivirus disable needed)
```powershell
hermes                          # Chat with Hermes (TUI)
hermes doctor                   # Diagnose problems
hermes model                    # Change model
```

### Telegram Gateway
- ✅ Auto-starts after installation
- ✅ Auto-starts after reboot (~30 seconds after login)
- Bot will respond to messages automatically

### Dashboard (requires antivirus disabled during install)
```powershell
hermes dashboard                # Opens http://localhost:9119
```
- ✅ Auto-starts after reboot (~60 seconds after login)

### Desktop (requires antivirus disabled during install)
```powershell
hermes desktop                  # Opens Electron desktop app
```

---

## Troubleshooting

### Dashboard/Desktop not working (antivirus blocked npm)

1. Temporarily disable antivirus real-time protection
2. Open PowerShell and run:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm run build -w web
```
3. Re-enable antivirus
4. Run `hermes dashboard` or `hermes desktop`

### Telegram bot not responding

1. Check gateway is running: `Get-Process -Name pythonw`
2. If not running: `hermes gateway start`
3. Check logs: `type %LOCALAPPDATA%\hermes\logs\gateway.log`

### After reboot - services not starting

- Check Startup Folder: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
- Should have: `HermesGateway.lnk`, `HermesDashboard.lnk`

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
**Updated:** 2026-07-14
