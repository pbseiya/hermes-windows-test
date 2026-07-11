---
marp: true
theme: default
paginate: true
header: "Course 0: Hermes + AI Harness"
footer: "Module 2: ติดตั้งและตั้งค่า Hermes"
style: |
  section {
    font-family: 'Sarabun', 'TH Sarabun New', sans-serif;
    background: white;
  }
  h1 {
    color: #2563eb;
    font-size: 2.5em;
  }
  h2 {
    color: #1e40af;
    font-size: 1.8em;
  }
  code {
    background: #f3f4f6;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'Fira Code', monospace;
  }
  pre code {
    display: block;
    padding: 16px;
    background: #1e293b;
    color: #e2e8f0;
    border-radius: 8px;
    font-size: 0.9em;
  }
  table {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
  }
  th {
    background: #3b82f6;
    color: white;
    padding: 12px;
    text-align: left;
  }
  td {
    padding: 10px;
    border-bottom: 1px solid #e5e7eb;
  }
  tr:nth-child(even) {
    background: #f9fafb;
  }
  .highlight {
    background: #fef3c7;
    padding: 16px;
    border-left: 4px solid #f59e0b;
    margin: 20px 0;
  }
  .success {
    background: #d1fae5;
    padding: 16px;
    border-left: 4px solid #10b981;
    margin: 20px 0;
  }
  .warning {
    background: #fee2e2;
    padding: 16px;
    border-left: 4px solid #ef4444;
    margin: 20px 0;
  }
  .info {
    background: #dbeafe;
    padding: 16px;
    border-left: 4px solid #3b82f6;
    margin: 20px 0;
  }
---

# Module 2: ติดตั้งและตั้งค่า Hermes

## 🎯 Learning Objectives

หลังจบ Module นี้ ผู้เรียนจะสามารถ:

1. ✅ รัน Quick Install Script ได้สำเร็จ (ไม่ต้อง sudo/admin)
2. ✅ สร้าง Telegram Bot Token ได้
3. ✅ เข้าใจ LiteLLM Proxy + qwen3.7-plus
4. ✅ เปิด Dashboard ได้ (http://localhost:9119)
5. ✅ ตั้งค่า Auto-start หลังรีสตาร์ทได้
6. ✅ ทดสอบการใช้งานพื้นฐานได้

---

# 🚀 วิธีติดตั้ง: Quick Install Script

## ง่ายที่สุด — รันสคริปต์เดียวจบ!

<div class="success">

**สคริปต์จะติดตั้งทุกอย่างอัตโนมัติ:**
- ✅ Node.js v22+ (nvm)
- ✅ Python 3.11+ (pyenv/embeddable)
- ✅ Git
- ✅ Hermes Agent (npm)
- ✅ LiteLLM Proxy config
- ✅ Telegram Bot config
- ✅ Auto-start หลังรีสตาร์ท

**ไม่ต้อง sudo/admin rights!**

</div>

---

# 📦 Step 1: รัน Quick Install Script

## Linux / macOS / WSL2

```bash
chmod +x quick-install.sh
./quick-install.sh
```

---

## Windows (PowerShell)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\quick-install.ps1
```

<div class="info">

**สคริปต์จะถาม 2 อย่าง:**
1. OpenRouter API Key (Free Tier — ข้ามได้)
2. **Telegram Bot Token** (สร้างก่อนรันสคริปต์)

</div>

---

# 🤖 Step 2: สร้าง Telegram Bot Token

## ทำก่อนรัน Quick Install Script!

### ขั้นตอนการสร้าง Bot

1. เปิด Telegram → ค้นหา `@BotFather`
2. ส่งคำสั่ง: `/newbot`
3. ตั้งชื่อ bot: "My Hermes Bot"
4. ตั้ง username: "my_hermes_bot" (ต้องลงท้ายด้วย `bot`)
5. รอ BotFather ตอบกลับ → **Copy Bot Token**

<div class="highlight">

**Bot Token ตัวอย่าง:**
```
1234567890:ABCdefGHIjklMNOpqrSTUvwxYZ
```

**เก็บ Token ไว้ให้ดี!** จะใช้ตอนรัน Quick Install Script

</div>

---

# 🔧 Step 2.5: ติดตั้ง Antigravity CLI (agy)

## ฟรี ใช้ Google Account — ไม่ต้องถาม password!

<div class="success">

**ทำไมต้องมี agy?**
- ใช้ Gemini ฟรีผ่าน Google Account ที่มีอยู่แล้ว
- **ไม่ต้องถาม password** ตอนติดตั้ง (user-space install)
- เหมาะสำหรับ **แก้ไข/ซ่อม hermes** เมื่อ hermes มีปัญหา
- ⚠️ Free tier มี rate limit — เพียงพอสำหรับการซ่อม hermes

</div>

### Linux / macOS

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

ติดตั้งที่ `~/.local/bin/agy`

### Windows (PowerShell)

```powershell
irm https://antigravity.google/cli/install.ps1 | iex
```

ติดตั้งที่ `%LOCALAPPDATA%\agy\bin`

### Windows (CMD)

```cmd
curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### หลังติดตั้ง

```bash
agy
# จะเปิด browser ให้ login ด้วย Google Account ครั้งแรก
```

---

# 🔑 Step 3: วาง API Keys ตอนรันสคริปต์

## Quick Install Script จะถาม

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ถาม API Keys และ Telegram Bot Token
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

สร้าง Telegram Bot Token (ทำตาม Slide Module 02):

  1. เปิด Telegram แล้วค้นหา @BotFather
  2. ส่งคำสั่ง /newbot
  3. ตั้งชื่อ bot (เช่น 'Hermes Assistant')
  4. ตั้ง username (เช่น 'my_hermes_bot')
  5. Copy token ที่ BotFather ให้ (รูปแบบ: 123456789:ABCdefGHI...)

วาง Telegram Bot Token (หรือกด Enter เพื่อข้าม): _
```

<div class="success">

**วาง Token ที่ได้จาก BotFather → กด Enter**

</div>

---

# 📂 Step 4: ตำแหน่งที่ติดตั้ง (User-Space)

## ทุกอย่างอยู่ใน User Directory — ไม่ต้อง sudo!

| โปรแกรม | Linux/macOS | Windows |
|---------|-------------|---------|
| Node.js v22+ | `~/.nvm/` | `~/.nvm/` หรือ `~/.local/node/` |
| Python 3.11+ | `~/.pyenv/` | `~/.local/python/` |
| Git | `~/.local/git/` | `~/.local/git/` |
| npm global | `~/.npm-global/` | `~/.npm-global/` |
| Hermes | `~/.npm-global/bin/hermes` | `~/.npm-global/hermes.cmd` |
| **Antigravity CLI** | `~/.local/bin/agy` | `~\AppData\Local\agy\bin\` |

---

# 🌐 Step 4.5: ตั้งค่า PATH อัตโนมัติ

## ทุกโปรแกรมเรียกใช้ได้จากทุก folder

<div class="success">

**สคริปต์เพิ่ม PATH โดยอัตโนมัติ** เพื่อให้เรียกใช้ `hermes`, `agy`, `node`, `python`, `git` ได้จากทุกที่

</div>

### Linux / macOS

เพิ่มใน shell config (`~/.bashrc` หรือ `~/.zshrc`):
- `$HOME/.local/bin` — Git, agy
- `$NVM_DIR` — Node.js (nvm)
- `$PYENV_ROOT/bin` — Python (pyenv)
- `$HOME/.npm-global/bin` — Hermes, npm global

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
- `%USERPROFILE%\.npm-global` — Hermes
- `%LOCALAPPDATA%\agy\bin` — Antigravity CLI

**หลังติดตั้งเสร็จ:**
เปิด PowerShell ใหม่เพื่อให้ PATH มีผล

---

# 🧠 Step 5: LiteLLM Proxy Configuration

## AI Model ที่ใช้: qwen3.7-plus

<div class="info">

**Course 0 ใช้ LiteLLM Proxy** — ไม่ต้องสมัคร API key แยก!

</div>

### Configuration (ตั้งค่าอัตโนมัติโดยสคริปต์)

```yaml
# ~/.hermes/config.yaml
model:
  provider: custom:litellm
  default: qwen3.7-plus

providers:
  litellm:
    base_url: https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1
    key_env: LITELLM_API_KEY
    transport: openai_chat
```

### .env

```bash
# ~/.hermes/.env
LITELLM_API_KEY=<your-api-key-here>
```

---

# 🔄 Step 6: Model Switching

## สลับ Models ได้ทันที

### ใน Session (สลับเร็วๆ)

```
/model anthropic/claude-sonnet-4
/model openai/gpt-4o
/model openrouter/meta-llama/llama-3
```

<div class="success">

**ข้อดี:** ไม่ต้อง restart Hermes
สลับ model ได้ทันทีขณะใช้งาน

</div>

### Provider Routing

```yaml
# ~/.hermes/config.yaml
provider_routing:
  sort: "throughput"  # "price", "latency"
```

### Fallback Configuration

```yaml
model:
  default: qwen3.7-plus
  fallbacks:
    - anthropic/claude-sonnet-4
    - openai/gpt-4o
```

---

# 📊 Models ที่แนะนำ

## เปรียบเทียบ Models

| Model | จุดเด่น | ราคา/1M tokens | ใช้เมื่อ |
|-------|---------|----------------|---------|
| **qwen3.7-plus** | **Course 0 default** | **ฟรี (LiteLLM)** | **ทุกงาน** |
| Claude Sonnet 4 | สมดุลดี | $3/$15 | งานทั่วไป |
| GPT-4o | เร็ว ฉลาด | $5/$15 | งานต้องการความเร็ว |
| Claude Opus 4 | ฉลาดสุด | $15/$75 | งานซับซ้อน |
| Llama 3 | ฟรี | $0 | ทดสอบ |

<div class="warning">

**หมายเหตุ:** ราคาอาจเปลี่ยนแปลง ตรวจสอบที่ provider อีกครั้ง

</div>

---

# 🌐 Step 7: Dashboard

## Web Dashboard — http://localhost:9119

<div class="success">

**Dashboard ทำให้คุณ:**
- ✅ ดู session history
- ✅ จัดการ cron jobs
- ✅ ดู tools และ skills
- ✅ ตรวจสอบ config
- ✅ ดู usage statistics

</div>

### เปิด Dashboard

```bash
# เริ่ม dashboard
hermes dashboard start
```

### เปิด browser

```
http://localhost:9119
```

<div class="info">

**Dashboard จะ auto-start หลังรีสตาร์ท**
ไม่ต้องรันคำสั่งซ้ำ!

</div>

---

# 📱 Step 8: Telegram Gateway

## เชื่อมต่อ Hermes กับ Telegram

### สิ่งที่ได้ตั้งค่าแล้ว

สคริปต์จะตั้งค่า Telegram Gateway อัตโนมัติ:

```yaml
# ~/.hermes/config.yaml
telegram:
  reactions: true  # ตอบโต้ได้ทันที
```

```bash
# ~/.hermes/.env
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHI...
```

### เริ่ม Gateway (ถ้ายังไม่เริ่ม)

```bash
hermes gateway start
```

### ทดสอบ

1. เปิด Telegram → หา bot ที่สร้าง
2. ส่งข้อความ: "สวัสดี"
3. Hermes จะตอบกลับ!

---

# ⚡ Step 9: Auto-Start หลังรีสตาร์ท

## Hermes จะเริ่มอัตโนมัติหลัง login

### Linux (systemd)

```bash
systemctl --user status hermes-gateway hermes-dashboard
systemctl --user start hermes-gateway
```

### macOS (launchd)

```bash
launchctl list | grep hermes
launchctl load ~/Library/LaunchAgents/com.hermes.gateway.plist
```

### Windows (Task Scheduler)

```powershell
schtasks /Query /TN "HermesGateway"
schtasks /Run /TN "HermesGateway"
```

---

# ✅ Step 10: ทดสอบการใช้งาน

## ทดสอบพื้นฐาน

```bash
# เริ่ม Hermes
hermes

# ส่งข้อความทดสอบ
You: สวัสดี ช่วยอะไรได้บ้าง?
Hermes: สวัสดีครับ! ผมเป็น AI Agent ช่วยทำงานได้หลายอย่าง...
```

## ทดสอบ Commands

```
/help          # ดูรายการ commands
/model         # ดู/เปลี่ยน model
/tools         # ดู tools ที่เปิดใช้
/config        # ดู configuration
/quit          # ออกจาก Hermes
```

## ทดสอบ Telegram

1. เปิด Telegram → หา bot
2. ส่ง: "ทดสอบ"
3. ดูว่า bot ตอบกลับไหม

---

# 🔧 Security & Permissions

## การตั้งค่าที่ตั้งไว้

<div class="info">

**สคริปต์ตั้งค่าให้แล้ว — ไม่ต้องทำเอง**

</div>

```yaml
# ~/.hermes/config.yaml

# ไม่ต้อง approve commands (YOLO mode)
approvals:
  mode: off

# Telegram ตอบโต้ได้ทันที
telegram:
  reactions: true

# แสดง credentials ไม่ต้องซ่อน
security:
  redact_secrets: false

# แสดงข้อมูลส่วนตัวไม่ต้องซ่อน
privacy:
  redact_pii: false
```

<div class="warning">

**หมายเหตุ:** การตั้งค่านี้เหมาะสำหรับ Course 0
สำหรับ production ควรเปลี่ยน `approvals.mode: manual`

</div>

---

# 🐛 Troubleshooting (1/3)

## ปัญหาที่พบบ่อย

### 1. `hermes: command not found`

<div class="warning">

**สาเหตุ:** PATH ไม่ได้ตั้ง

</div>

**แก้ไข:**
```bash
# Linux / macOS
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

```powershell
# Windows
$env:Path = "$env:USERPROFILE\.npm-global;$env:Path"
```

### 2. `nvm: command not found`

**แก้ไข:**
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

---

# 🐛 Troubleshooting (2/3)

### 3. `pyenv: command not found`

**แก้ไข:**
```bash
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

### 4. `node is not recognized` (Windows)

**แก้ไข:**
```powershell
$env:Path = "$env:USERPROFILE\.local\node;$env:Path"
# หรือ
$env:Path = "$env:USERPROFILE\.nvm\v22.14.0;$env:Path"
```

### 5. `python is not recognized` (Windows)

**แก้ไข:**
```powershell
$env:Path = "$env:USERPROFILE\.local\python;$env:USERPROFILE\.local\python\Scripts;$env:Path"
```

---

# 🐛 Troubleshooting (3/3)

### 6. `API key invalid`

<div class="warning">

**สาเหตุ:** LiteLLM API key ไม่ถูกต้อง

</div>

**แก้ไข:**
```bash
# ตรวจสอบ .env
cat ~/.hermes/.env

# ควรเห็น:
# LITELLM_API_KEY=<your-api-key-here>
```

### 7. Telegram bot ไม่ตอบ

**แก้ไข:**
```bash
# ตรวจสอบ gateway status
# Linux
systemctl --user status hermes-gateway

# Windows
schtasks /Query /TN "HermesGateway"

# เริ่ม gateway ใหม่
hermes gateway start
```

### 8. Dashboard เปิดไม่ได้

**แก้ไข:**
```bash
# เริ่ม dashboard
hermes dashboard start

# ตรวจสอบ port
# Linux
ss -tlnp | grep 9119

# Windows
netstat -ano | findstr 9119
```

---

# 📋 Checklist

## หลังจบ Module นี้ ผู้เรียนควร:

- [ ] รัน Quick Install Script สำเร็จ
- [ ] สร้าง Telegram Bot Token ได้
- [ ] วาง Token ตอนรันสคริปต์
- [ ] ทดสอบ `hermes` CLI ได้
- [ ] เปิด Dashboard ได้ (http://localhost:9119)
- [ ] ทดสอบ Telegram bot ได้
- [ ] เข้าใจว่าทุกอย่าง auto-start หลังรีสตาร์ท
- [ ] เข้าใจวิธีใช้ `/model`, `/tools`, `/config`

---

# 🎯 Next Step

## หลังจบ Module 2

ไปต่อที่ **Lab 1: ทดสอบ Vision + Dashboard**

**สิ่งที่ต้องทำ:**
1. ทดสอบ `vision_analyze` กับภาพต่างๆ
2. เปิดและใช้งาน Dashboard (http://localhost:9119)
3. ส่งข้อความหา Telegram bot
4. ทดสอบสลับ models ด้วย `/model`

---

# 📚 เอกสารเพิ่มเติม

## Links สำคัญ

- **GitHub:** https://github.com/NousResearch/hermes-agent
- **Documentation:** https://hermes-agent.nousresearch.com/docs
- **LiteLLM Proxy:** https://litellm-proxy-gateway.pbseiyacpro7.workers.dev

## Quick Install Scripts

| ไฟล์ | ระบบปฏิบัติการ | วิธีใช้ |
|------|----------------|---------|
| `quick-install.sh` | Linux / macOS / WSL2 | `./quick-install.sh` |
| `quick-install.ps1` | Windows (PowerShell) | `.\quick-install.ps1` |
| `quick-install.bat` | Windows (CMD fallback) | `quick-install.bat` |

## API Keys

- **OpenRouter (Free):** https://openrouter.ai/keys
- **LiteLLM:** ใช้ key ที่ให้ใน Course 0

---

# จบ Module 2

## 🎉 พร้อมทำ Lab 1!

<div class="success">

**ตอนนี้คุณมี:**

- ✅ Hermes CLI ติดตั้งแล้ว (user-space)
- ✅ LiteLLM Proxy + qwen3.7-plus
- ✅ Telegram Bot พร้อมใช้
- ✅ Dashboard ที่ http://localhost:9119
- ✅ Auto-start หลังรีสตาร์ท
- ✅ เข้าใจวิธีสลับ models

</div>

**ไปต่อที่ Lab 1: ทดสอบ Vision + Dashboard** 🚀
