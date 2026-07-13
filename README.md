# Hermes Agent Quick Install

เธเธนเนเธกเธทเธญเธ•เธดเธ”เธ•เธฑเนเธ Hermes Agent เธชเธณเธซเธฃเธฑเธเธเธนเนเน€เธฃเธตเธขเธ Course 0

---

## โก One-liner Commands

### เธ•เธดเธ”เธ•เธฑเนเธ
เน€เธเธดเธ” **PowerShell** เนเธฅเนเธงเธฃเธฑเธ:
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### เธ–เธญเธเธเธฒเธฃเธ•เธดเธ”เธ•เธฑเนเธ
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
```

---

## ๐“ เธชเธดเนเธเธ—เธตเนเธ•เนเธญเธเน€เธ•เธฃเธตเธขเธกเธเนเธญเธเธ•เธดเธ”เธ•เธฑเนเธ

| เธฃเธฒเธขเธเธฒเธฃ | เธงเธดเธเธตเธซเธฒ |
|--------|--------|
| **LiteLLM API Key** | เนเธ”เนเธเธฒเธ instructor (Course 0) |
| **Telegram Bot Token** | เธชเธฃเนเธฒเธเธเธฒเธ @BotFather เนเธ Telegram (เธ”เธนเธงเธดเธเธตเนเธ Slide Module 02) |
| **Telegram Chat ID** | เธเนเธเธซเธฒ @userinfobot เนเธ Telegram โ’ เธเธ” /start โ’ เธเธฐเนเธ”เนเธ•เธฑเธงเน€เธฅเธ |

> เนเธกเนเธ•เนเธญเธเนเธเน admin rights โ€” เธ—เธธเธเธญเธขเนเธฒเธเธ•เธดเธ”เธ•เธฑเนเธเนเธ user folder

---

## ๐”ง เธชเธเธฃเธดเธเธ•เนเธ•เธดเธ”เธ•เธฑเนเธเธญเธฐเนเธฃเนเธซเนเธญเธฑเธ•เนเธเธกเธฑเธ•เธด

- Git Portable v2.47+
- Node.js v22+ (portable)
- Python 3.11+ (embeddable)
- uv (Python package manager)
- Hermes Agent v0.18+ (เธเธฃเนเธญเธก Dashboard, Desktop, TUI)
- Antigravity CLI (agy) โ€” เธชเธณเธซเธฃเธฑเธเธเนเธญเธก hermes เธขเธฒเธกเธเธธเธเน€เธเธดเธ
- เธ•เธฑเนเธเธเนเธฒ auto-start เธซเธฅเธฑเธ login

---

## ๐€ เธซเธฅเธฑเธเธ•เธดเธ”เธ•เธฑเนเธเน€เธชเธฃเนเธ

```powershell
hermes                          # เน€เธฃเธดเนเธกเธชเธเธ—เธเธฒเธเธฑเธ Hermes (TUI)
hermes dashboard                # เน€เธเธดเธ” Web Dashboard
hermes desktop                  # เน€เธเธดเธ” Desktop App (Electron)
hermes model                    # เน€เธเธฅเธตเนเธขเธ model
hermes doctor                   # เธงเธดเธเธดเธเธเธฑเธขเธเธฑเธเธซเธฒ
```

**Dashboard:** http://localhost:9119

**เน€เธฃเธดเนเธก Telegram Gateway + Dashboard เธญเธฑเธ•เนเธเธกเธฑเธ•เธดเธซเธฅเธฑเธ login:**
```powershell
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

---

## โ“ เธเธณเธ–เธฒเธกเธ—เธตเนเธเธเธเนเธญเธข

### Q: เธ•เนเธญเธเนเธเน admin rights เนเธซเธก?
**A:** เนเธกเนเธ•เนเธญเธ เธ—เธธเธเธญเธขเนเธฒเธเธ•เธดเธ”เธ•เธฑเนเธเนเธ user folder เธเธญเธเธเธธเธ“

### Q: เนเธเนเน€เธงเธฅเธฒเธเธฒเธเนเธเนเนเธซเธ?
**A:** เธเธฃเธฐเธกเธฒเธ“ 10-20 เธเธฒเธ—เธต เธเธถเนเธเธญเธขเธนเนเธเธฑเธเธเธงเธฒเธกเน€เธฃเนเธง internet เนเธฅเธฐ antivirus

### Q: เธ•เนเธญเธ restart เน€เธเธฃเธทเนเธญเธเนเธซเธก?
**A:** เนเธกเนเธ•เนเธญเธ เนเธ•เนเธเธงเธฃเน€เธเธดเธ” PowerShell เนเธซเธกเนเธซเธฅเธฑเธเธ•เธดเธ”เธ•เธฑเนเธเน€เธชเธฃเนเธ

### Q: เธ•เธดเธ”เธ•เธฑเนเธเนเธกเนเธชเธณเน€เธฃเนเธ / Dashboard เน€เธเธดเธ”เนเธกเนเนเธ”เน เธ—เธณเธขเธฑเธเนเธ?
**A:** เธฃเธฑเธเธเธณเธชเธฑเนเธเธเธตเนเน€เธเธทเนเธญเธเนเธญเธก:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm install --workspace web --no-fund --no-audit
npm run build -w web
```
เธ–เนเธฒเธขเธฑเธเนเธกเนเนเธ”เน เนเธซเนเธ–เธญเธเธเธฒเธฃเธ•เธดเธ”เธ•เธฑเนเธเนเธฅเนเธงเธ•เธดเธ”เธ•เธฑเนเธเนเธซเธกเน:
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-uninstall.ps1 | iex
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### Q: Telegram bot เนเธกเนเธ•เธญเธ?
**A:** เธ•เธฃเธงเธเธชเธญเธเธงเนเธฒ:
1. เธ•เธฑเนเธเธเนเธฒ Bot Token เธ–เธนเธเธ•เนเธญเธ
2. เธ•เธฑเนเธเธเนเธฒ Chat ID เธ–เธนเธเธ•เนเธญเธ (เธซเธฒเนเธ”เนเธเธฒเธ @userinfobot)
3. เธฃเธฑเธ `hermes gateway start` เนเธฅเนเธง

### Q: เนเธเน agy เนเธเนเธเธฑเธเธซเธฒ hermes เนเธ”เนเธญเธขเนเธฒเธเนเธฃ?
**A:** เธฃเธฑเธ `agy` เนเธฅเนเธง login เธ”เนเธงเธข Google Account (เธเธฃเธต) เนเธฅเนเธงเธเธญเธเนเธซเน agy เธเนเธงเธขเธเนเธญเธก hermes

---

## ๐“ เนเธเธฅเนเนเธ Repository

| เนเธเธฅเน | เธเธณเธญเธเธดเธเธฒเธข |
|------|----------|
| `quick-install.ps1` | PowerShell script เธชเธณเธซเธฃเธฑเธเธ•เธดเธ”เธ•เธฑเนเธ (one-liner) |
| `quick-uninstall.ps1` | PowerShell script เธชเธณเธซเธฃเธฑเธเธ–เธญเธเธเธฒเธฃเธ•เธดเธ”เธ•เธฑเนเธ (one-liner) |
| `quick-install.bat` | Batch file เธชเธณเธซเธฃเธฑเธเธ”เธฑเธเน€เธเธดเธฅเธเธฅเธดเธ |
| `02-hermes-setup.html` | Slides (เน€เธเธดเธ”เนเธ browser) |
| `02-hermes-setup.md` | Slides (Markdown source) |
| `INSTALLATION_GUIDE.md` | เธเธนเนเธกเธทเธญเธ•เธดเธ”เธ•เธฑเนเธเธเธเธฑเธเน€เธ•เนเธก |
| `TESTING_GUIDE.md` | เธเธนเนเธกเธทเธญเธ—เธ”เธชเธญเธเธซเธฅเธฑเธเธ•เธดเธ”เธ•เธฑเนเธ |

---

**เธชเธฃเนเธฒเธเนเธ”เธข:** Hermes Agent Training Team
**เธญเธฑเธเน€เธ”เธ—เธฅเนเธฒเธชเธธเธ”:** 2026-07-13
