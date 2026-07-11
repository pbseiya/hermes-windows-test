# Quick Install Scripts

สคริปต์ติดตั้ง Hermes Agent แบบอัตโนมัติ **รองรับทั้ง 3 OS และไม่ต้องใช้ sudo/admin rights**

## 📦 ไฟล์สคริปต์

| ไฟล์ | ระบบปฏิบัติการ | วิธีใช้ |
|------|----------------|---------|
| `quick-install.sh` | Linux / macOS / WSL2 | `./quick-install.sh` |
| `quick-install.ps1` | Windows (PowerShell) | `.\quick-install.ps1` |
| `quick-install.bat` | Windows (CMD fallback) | `quick-install.bat` |

## 🚀 วิธีใช้งาน

### Linux / macOS / WSL2

```bash
# ทำให้ executable
chmod +x quick-install.sh

# รันแบบ interactive (ถาม API key)
./quick-install.sh

# หรือระบุ API key ตั้งแต่แรก
./quick-install.sh "sk-or-v1-***"
```

### Windows (PowerShell)

```powershell
# เปิด PowerShell
# ตั้งค่า execution policy (ครั้งแรกเท่านั้น)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# รันสคริปต์
.\quick-install.ps1

# หรือระบุ API key
.\quick-install.ps1 -OpenRouterKey "sk-or-v1-***"
```

### Windows (CMD)

```cmd
# ดับเบิลคลิก quick-install.bat
# หรือรันจาก CMD
quick-install.bat
```

## 🎯 สิ่งที่สคริปต์ทำ

### Step 1: ตรวจสอบและติดตั้ง Prerequisites อัตโนมัติ (User-Space)

#### Linux / macOS
- ✅ **curl** — ติดตั้งอัตโนมัติถ้าไม่มี (อาจต้องการ sudo ครั้งแรก)
- ✅ **Git** — ติดตั้งจาก binary release หรือ Homebrew → `~/.local/git/`
- ✅ **Node.js v22+** — ติดตั้งด้วย **nvm** → `~/.nvm/`
- ✅ **npm** — มากับ nvm
- ✅ **Python 3.11+** — ติดตั้งด้วย **pyenv** → `~/.pyenv/`
- ✅ **pip** — ติดตั้งอัตโนมัติถ้าไม่มี

**ตั้งค่า PATH ใน shell config (.bashrc/.zshrc) อัตโนมัติ:**
- `$HOME/.local/bin` (Git, agy)
- `$NVM_DIR` (Node.js via nvm)
- `$PYENV_ROOT/bin` (Python via pyenv)
- `$HOME/.npm-global/bin` (Hermes, npm global packages)

#### Windows
- ✅ **Git** — ติดตั้ง **Portable Git** → `~/.local/git/`
- ✅ **Node.js v22+** — ติดตั้งด้วย **nvm-windows** หรือ **portable** → `~/.nvm/` หรือ `~/.local/node/`
- ✅ **npm** — มากับ Node.js
- ✅ **Python 3.11+** — ติดตั้ง **embeddable package** → `~/.local/python/`
- ✅ **pip** — ติดตั้งอัตโนมัติด้วย `get-pip.py`

**ตั้งค่า User Environment Variable PATH อัตโนมัติ:**
- `%USERPROFILE%\.local\git\bin` (Git)
- `%USERPROFILE%\.nvm` (Node.js via nvm)
- `%USERPROFILE%\.local\node` (Node.js portable)
- `%USERPROFILE%\.local\python` (Python)
- `%USERPROFILE%\.npm-global` (Hermes, npm global packages)
- `%LOCALAPPDATA%\agy\bin` (Antigravity CLI)

### Step 2: ติดตั้ง Hermes Agent ด้วย npm (User-Space)
- ✅ ตั้งค่า npm prefix → `~/.npm-global/`
- ✅ รัน `npm install -g @nousresearch/hermes-agent`
- ✅ เพิ่ม PATH อัตโนมัติใน shell config / User Environment Variable

### Step 2.5: ติดตั้ง Antigravity CLI (agy) — ฟรี ใช้ Google Account

**ทำไมต้องมี agy?**
- ใช้ Gemini ฟรีผ่าน Google Account ที่มีอยู่แล้ว
- **ไม่ต้องถาม password** ตอนติดตั้ง (user-space install)
- เหมาะสำหรับ **แก้ไข/ซ่อม hermes** เมื่อ hermes มีปัญหา
- ⚠️ Free tier มี rate limit — เพียงพอสำหรับการซ่อม hermes

**Linux / macOS:**
```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
# ติดตั้งที่ ~/.local/bin/agy
# เพิ่ม PATH ใน shell config อัตโนมัติ
```

**Windows (PowerShell):**
```powershell
irm https://antigravity.google/cli/install.ps1 | iex
# ติดตั้งที่ %LOCALAPPDATA%\agy\bin
# เพิ่ม User PATH อัตโนมัติ
```

**Windows (CMD):**
```cmd
curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**หลังติดตั้ง:**
```bash
agy
# จะเปิด browser ให้ login ด้วย Google Account ครั้งแรก
```

---

## 🌐 ตั้งค่า PATH อัตโนมัติ

**ทุกโปรแกรมถูกเพิ่มใน PATH โดยอัตโนมัติ เพื่อให้เรียกใช้ได้จากทุก folder**

### Linux / macOS
เพิ่มใน shell config (`~/.bashrc` หรือ `~/.zshrc`):
- `$HOME/.local/bin` — Git, agy
- `$NVM_DIR/nvm.sh` — Node.js (nvm)
- `$PYENV_ROOT/bin` — Python (pyenv)
- `$HOME/.npm-global/bin` — Hermes, npm global packages

**หลังติดตั้งเสร็จ:**
```bash
source ~/.bashrc  # หรือ source ~/.zshrc
```

### Windows
เพิ่มใน User Environment Variable:
- `%USERPROFILE%\.local\git\bin` — Git
- `%USERPROFILE%\.nvm` — Node.js (nvm)
- `%USERPROFILE%\.local\node` — Node.js (portable)
- `%USERPROFILE%\.local\python` — Python
- `%USERPROFILE%\.npm-global` — Hermes, npm global packages
- `%LOCALAPPDATA%\agy\bin` — Antigravity CLI

**หลังติดตั้งเสร็จ:**
เปิด PowerShell ใหม่เพื่อให้ PATH มีผล

### Step 3: ถาม API Keys และ Telegram Bot Token
- ✅ ถาม OpenRouter API Key (Free Tier)
- ✅ ถาม Telegram Bot Token (สร้างจาก @BotFather)
- ✅ ตรวจสอบรูปแบบของ keys

### Step 4: ตั้งค่า Hermes
- ✅ สร้าง `~/.hermes/.env` พร้อม:
  - `LITELLM_API_KEY` — LiteLLM Proxy (Course 0)
  - `OPENROUTER_API_KEY` — OpenRouter Free Tier
  - `TELEGRAM_BOT_TOKEN` — Telegram Gateway
- ✅ สร้าง `~/.hermes/config.yaml`:
  - Model: `qwen3.7-plus` ผ่าน LiteLLM Proxy
  - Dashboard: `http://localhost:9119`
  - Security:
    - `approvals: off` — ไม่ต้อง approve commands
    - `telegram.reactions: true` — ตอบโต้ได้ทันที
    - `security.redact_secrets: false` — แสดง credentials
    - `privacy.redact_pii: false` — แสดงข้อมูลส่วนตัว
- ✅ สำรองไฟล์เดิมก่อนเขียนทับ

### Step 5: ตั้งค่า Auto-Start หลังรีสตาร์ท
- ✅ **Linux**: สร้าง systemd user services
  - `hermes-gateway.service` (Telegram)
  - `hermes-dashboard.service` (Dashboard)
- ✅ **macOS**: สร้าง launchd plists
  - `com.hermes.gateway.plist`
  - `com.hermes.dashboard.plist`
- ✅ **Windows**: สร้าง Task Scheduler tasks หรือ Startup Folder
  - `HermesGateway` (Telegram)
  - `HermesDashboard` (Dashboard)

### Step 6: ตรวจสอบการติดตั้ง
- ✅ ทดสอบ `hermes --version`
- ✅ แสดงคำสั่งที่ควรใช้

### Step 7: สรุปผล
- ✅ แสดงตำแหน่งที่ติดตั้งทุกโปรแกรม
- ✅ แสดงการตั้งค่า (Model, Dashboard, Telegram, Auto-start)
- ✅ แสดงคำสั่งเริ่มต้น services

## 🔑 OpenRouter API Key (ฟรี)

### วิธีสมัคร

1. เปิด https://openrouter.ai/keys
2. คลิก **Sign in with Google** (ใช้ Google Account ที่มีอยู่แล้ว)
3. คลิก **+ Create Key**
4. ตั้งชื่อ key (เช่น "Hermes Course")
5. Copy key (ขึ้นต้นด้วย `sk-or-v1-...`)

### Models ฟรีที่ใช้ได้

| Model | จุดเด่น | ใช้เมื่อ |
|-------|---------|---------|
| `google/gemini-2.5-flash` | เร็ว, ถูก | งานทั่วไป |
| `google/gemini-2.5-flash-lite` | เร็วมาก | งานง่ายๆ |
| `meta-llama/llama-3.3-70b` | ฉลาด | งานซับซ้อน |

ดู models ทั้งหมด: https://openrouter.ai/models?q=free

## 📂 ตำแหน่งที่ติดตั้ง (User-Space)

### Linux / macOS
```
~/.nvm/              # Node.js (nvm)
~/.pyenv/            # Python (pyenv)
~/.npm-global/       # npm global packages
~/.npm-global/bin/hermes  # Hermes executable
~/.local/git/        # Git (ถ้าติดตั้งจาก binary)
~/.local/bin/        # User binaries
~/.hermes/           # Hermes config
```

### Windows
```
%USERPROFILE%\.nvm\           # Node.js (nvm-windows)
%USERPROFILE%\.local\node\    # Node.js (portable)
%USERPROFILE%\.local\python\  # Python (embeddable)
%USERPROFILE%\.local\git\     # Git (portable)
%USERPROFILE%\.npm-global\    # npm global packages
%USERPROFILE%\.npm-global\hermes.cmd  # Hermes executable
%USERPROFILE%\.hermes\        # Hermes config
```

## 🛠️ Options

### Linux / macOS

```bash
# ข้ามการติดตั้ง (ใช้ hermes ที่มีอยู่แล้ว)
./quick-install.sh --skip-install

# บังคับติดตั้งทับ
./quick-install.sh --force

# ไม่ถามอะไร (ใช้ default)
./quick-install.sh --non-interactive
```

### Windows (PowerShell)

```powershell
# ข้ามการติดตั้ง
.\quick-install.ps1 -SkipInstall

# บังคับติดตั้งทับ
.\quick-install.ps1 -Force

# ระบุ API key
.\quick-install.ps1 -OpenRouterKey "sk-or-v1-***"
```

## 🐛 Troubleshooting

### Linux / macOS

**ปัญหา:** `Permission denied`
```bash
chmod +x quick-install.sh
```

**ปัญหา:** `hermes: command not found`
```bash
# เพิ่ม PATH
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

# หรือเพิ่มใน ~/.bashrc / ~/.zshrc
echo 'export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**ปัญหา:** `nvm: command not found`
```bash
# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

**ปัญหา:** `pyenv: command not found`
```bash
# Load pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

### Windows

**ปัญหา:** `cannot be loaded because running scripts is disabled`
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**ปัญหา:** `hermes is not recognized`
```powershell
# เปิด PowerShell ใหม่
# หรือใช้ path เต็ม
& "$env:USERPROFILE\.npm-global\hermes.cmd"
```

**ปัญหา:** `git is not recognized`
```powershell
# เพิ่ม PATH
$env:Path = "$env:USERPROFILE\.local\git\bin;$env:USERPROFILE\.local\git\cmd;$env:Path"
```

**ปัญหา:** `node is not recognized`
```powershell
# เพิ่ม PATH
$env:Path = "$env:USERPROFILE\.local\node;$env:Path"
# หรือ
$env:Path = "$env:USERPROFILE\.nvm\v22.14.0;$env:Path"
```

**ปัญหา:** `python is not recognized`
```powershell
# เพิ่ม PATH
$env:Path = "$env:USERPROFILE\.local\python;$env:USERPROFILE\.local\python\Scripts;$env:Path"
```

## 📝 สิ่งที่ต้องเตรียมก่อนรัน

### ทุก OS
- ✅ Internet connection
- ✅ Google Account (สำหรับสมัคร OpenRouter)

### Linux / macOS
- ✅ curl (สคริปต์จะติดตั้งให้ถ้าไม่มี)
- ✅ build-essential (สำหรับ pyenv — สคริปต์จะติดตั้งให้)

### Windows
- ✅ PowerShell 5.1+ (มีอยู่แล้วใน Windows 10/11)
- ✅ Internet connection

## 🎓 ใช้ใน Course 0

สคริปต์นี้ใช้ในงาน **Course 0: Hermes + AI Harness** เพื่อ:
1. ลดเวลาติดตั้งจาก 30 นาที → 5 นาที
2. ทำให้ผู้เรียนทุกคนมี environment เดียวกัน
3. ลดปัญหา "ติดตั้งไม่ได้" ในวันอบรม
4. ใช้ OpenRouter Free Tier (ไม่ต้องจ่ายเงิน)
5. **ไม่ต้องใช้ sudo/admin rights** — เหมาะกับคอมพิวเตอร์องค์กร

## 📚 เอกสารเพิ่มเติม

- [Hermes Agent Documentation](https://hermes-agent.nousresearch.com/docs)
- [OpenRouter](https://openrouter.ai/)
- [nvm (Node Version Manager)](https://github.com/nvm-sh/nvm)
- [pyenv (Python Version Manager)](https://github.com/pyenv/pyenv)
- [nvm-windows](https://github.com/coreybutler/nvm-windows)
- [Course 0 Materials](../../MATERIALS_INDEX.md)

---

**สร้างโดย:** Hermes Agent Training Team  
**อัพเดทล่าสุด:** 2026-07-09  
**License:** MIT
