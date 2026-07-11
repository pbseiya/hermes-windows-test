# 📚 Installation Guide - Course 0: Hermes + AI Harness

คู่มือการติดตั้ง Hermes Agent สำหรับผู้เรียน Course 0

**เวอร์ชัน:** 1.1 (อัพเดทล่าสุด: 2026-07-11)

---

## 🎯 ภาพรวม

สคริปต์ติดตั้งจะทำงาน **7 ขั้นตอน** ตามลำดับด้านล่าง ผู้เรียนไม่ต้องทำอะไรนอกจาก **รันสคริปต์ครั้งเดียว** และ **ตอบคำถาม** เมื่อถูกถาม

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Prerequisites (Git, Node.js v22+, Python 3.11+)   │
│  ↓                                                          │
│  Step 2: Hermes Agent (npm install)                         │
│  ↓                                                          │
│  Step 2.5: Antigravity CLI (backup tool)                    │
│  ↓                                                          │
│  Step 3: ถาม API Keys (OpenRouter + Telegram)               │
│  ↓                                                          │
│  Step 4: ตั้งค่า .env + config.yaml                         │
│  ↓                                                          │
│  Step 5: Auto-start services                                │
│  ↓                                                          │
│  Step 6: ตรวจสอบ + สรุปผล                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 รายละเอียดแต่ละขั้นตอน

### Step 1: ติดตั้ง Prerequisites (User-Space)

**ติดตั้งอะไร:**
- **Git** - สำหรับจัดการโค้ดและดาวน์โหลดสคริปต์
- **Node.js v22+** - รัน Hermes Agent (ใช้ nvm หรือ NodeSource)
- **Python 3.11+** - สำหรับ tools และ scripts (ใช้ pyenv)
- **pip** - จัดการ Python packages

**ทำไมต้องติดตั้ง:**
Hermes Agent ต้องการ Node.js และ Python เพื่อทำงาน

**ตำแหน่งที่ติดตั้ง:**
- Linux/macOS: `~/.nvm/`, `~/.pyenv/`, `~/.local/bin/`
- Windows: `%USERPROFILE%\.nvm\`, `%USERPROFILE%\.local\python\`

**ใช้เวลานานแค่ไหน:** 2-5 นาที (ขึ้นอยู่กับความเร็ว Internet)

**หมายเหตุ:** ทุกโปรแกรมติดตั้งใน user-space ไม่ต้อง sudo/admin

---

### Step 2: ติดตั้ง Hermes Agent (npm)

**ติดตั้งอะไร:**
- **Hermes Agent** - AI Agent CLI จาก Nous Research

**ทำไมต้องติดตั้ง:**
เป็นโปรแกรมหลักที่เราจะใช้ใน Course 0

**ตำแหน่งที่ติดตั้ง:**
- Linux/macOS: `~/.npm-global/bin/hermes`
- Windows: `%USERPROFILE%\.npm-global\hermes.cmd`

**ใช้เวลานานแค่ไหน:** 1-3 นาที

**หมายเหตุ:** ติดตั้งผ่าน npm ใน user-space ไม่ต้อง sudo

---

### Step 2.5: ติดตั้ง Antigravity CLI (agy)

**ติดตั้งอะไร:**
- **Antigravity CLI (agy)** - Gemini CLI จาก Google (ฟรี)

**ทำไมต้องติดตั้ง:**
เป็นเครื่องมือสำรองสำหรับซ่อม Hermes เมื่อมีปัญหา

**ตำแหน่งที่ติดตั้ง:**
- Linux/macOS: `~/.local/bin/agy`
- Windows: `%LOCALAPPDATA%\agy\bin\`

**ใช้เวลานานแค่ไหน:** 30 วินาที - 1 นาที

**หมายเหตุ:** 
- ต้อง login ด้วย Google Account ครั้งแรก (ฟรี)
- ไม่ต้องถาม password ตอนติดตั้ง
- Free tier มี rate limit แต่เพียงพอสำหรับการซ่อม Hermes

---

### Step 3: ถาม API Keys

**ถามอะไร:**
1. **OpenRouter API Key** - สำหรับใช้ AI models ฟรี
2. **Telegram Bot Token** - สำหรับเชื่อมต่อ Telegram (ถ้าต้องการ)

**ทำไมต้องถาม:**
- OpenRouter ให้ใช้ Gemini, Claude, GPT ฟรี (มี rate limit)
- Telegram Bot ให้คุยกับ Hermes ผ่าน Telegram

**ต้องเตรียมอะไรก่อน:**
- **OpenRouter**: สมัครที่ https://openrouter.ai/keys (ใช้ Google Account)
- **Telegram**: สร้าง bot ที่ @BotFather บน Telegram

**ใช้เวลานานแค่ไหน:** 2-5 นาที (รวมเวลาสมัคร)

**หมายเหตุ:** สามารถกด Enter เพื่อข้ามได้ถ้ายังไม่มี

---

### Step 4: ตั้งค่า .env + config.yaml

**ตั้งค่าอะไร:**
- **`~/.hermes/.env`** - เก็บ API keys
  - `LITELLM_API_KEY` - LiteLLM Proxy (Course 0)
  - `OPENROUTER_API_KEY` - OpenRouter Free Tier
  - `TELEGRAM_BOT_TOKEN` - Telegram Bot Token
- **`~/.hermes/config.yaml`** - ตั้งค่า Hermes
  - Model: `qwen3.7-plus` ผ่าน LiteLLM Proxy
  - Dashboard: `http://localhost:9119`
  - Security: `approvals=off`, `redact_secrets=false`, `redact_pii=false`
  - Telegram: `reactions=true`

**ทำไมต้องตั้งค่า:**
Hermes ต้องการ API keys และ configuration เพื่อทำงาน

**ใช้เวลานานแค่ไหน:** 5 วินาที (อัตโนมัติ)

**หมายเหตุ:** 
- LiteLLM API key ถูกตั้งค่าให้แล้ว (ไม่ต้องสมัคร)
- Backup ไฟล์เดิมอัตโนมัติก่อนเขียนทับ

---

### Step 5: ตั้งค่า Auto-Start

**ตั้งค่าอะไร:**
- **Linux**: สร้าง systemd user services
  - `hermes-gateway.service` - Telegram Gateway
  - `hermes-dashboard.service` - Web Dashboard
- **macOS**: สร้าง launchd plists
- **Windows**: สร้าง Task Scheduler tasks

**ทำไมต้องตั้งค่า:**
ให้ Hermes เริ่มอัตโนมัติหลังรีสตาร์ทเครื่อง

**ใช้เวลานานแค่ไหน:** 2 วินาที (อัตโนมัติ)

**หมายเหตุ:** ไม่ต้อง sudo/admin rights

---

### Step 6: ตรวจสอบ + สรุปผล

**ตรวจสอบอะไร:**
- ทดสอบ `hermes --version`
- ตรวจสอบว่า hermes อยู่ใน PATH
- แสดงตำแหน่งที่ติดตั้งทุกโปรแกรม

**สรุปอะไร:**
- แสดงคำสั่งเริ่มต้นใช้งาน
- แสดงลิงก์ Dashboard: http://localhost:9119
- แสดงวิธีทดสอบ Telegram Bot

**ใช้เวลานานแค่ไหน:** 2 วินาที

---

## 🌐 PATH Configuration

**ทุกโปรแกรมถูกเพิ่มใน PATH โดยอัตโนมัติ** เพื่อให้เรียกใช้ได้จากทุก folder

### Linux / macOS

เพิ่มใน shell config (`~/.bashrc` หรือ `~/.zshrc`):
- `$HOME/.local/bin` — Git, agy
- `$NVM_DIR` — Node.js (nvm)
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

---

## 🚀 วิธีใช้งาน

### Windows (คอมพิวเตอร์บริษัท)

**วิธีที่ง่ายที่สุด:**
1. ดาวน์โหลดไฟล์จาก GitHub: https://github.com/pbseiya/hermes-windows-test
2. แตกไฟล์
3. ดับเบิลคลิก `install-windows.bat`
4. ทำตามคำแนะนำบนหน้าจอ
5. เมื่อถาม API key ให้ใส่ OpenRouter API key ของคุณ

**ถ้ามีปัญหา:**
- เปิด PowerShell แล้วรัน: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- ลองรัน `install-windows.bat` อีกครั้ง

---

### macOS

**วิธีติดตั้ง:**
1. ดาวน์โหลดไฟล์จาก GitHub
2. แตกไฟล์
3. เปิด Terminal
4. ไปที่โฟลเดอร์ที่แตกไฟล์: `cd ~/Downloads/hermes-windows-test-main`
5. รันคำสั่ง: `chmod +x install-mac.sh`
6. รันคำสั่ง: `./install-mac.sh`
7. ทำตามคำแนะนำบนหน้าจอ

---

### Linux

**วิธีติดตั้ง:**
1. ดาวน์โหลดไฟล์จาก GitHub
2. แตกไฟล์
3. เปิด Terminal
4. ไปที่โฟลเดอร์ที่แตกไฟล์: `cd ~/Downloads/hermes-windows-test-main`
5. รันคำสั่ง: `chmod +x install-linux.sh`
6. รันคำสั่ง: `./install-linux.sh`
7. ทำตามคำแนะนำบนหน้าจอ

---

## 📊 สรุปเวลาติดตั้ง

| ขั้นตอน | เวลา |
|---------|------|
| Step 1: Prerequisites | 2-5 นาที |
| Step 2: Hermes Agent | 1-3 นาที |
| Step 2.5: Antigravity CLI | 30 วินาที |
| Step 3: ถาม API Keys | 2-5 นาที |
| Step 4: ตั้งค่า | 5 วินาที |
| Step 5: Auto-start | 2 วินาที |
| Step 6: ตรวจสอบ | 2 วินาที |
| **รวม** | **6-14 นาที** |

---

## ✅ Checklist หลังติดตั้ง

- [ ] รัน `hermes --version` ได้
- [ ] รัน `hermes` เปิด CLI ได้
- [ ] ส่งข้อความ "สวัสดี" ได้
- [ ] เปิด Dashboard ที่ http://localhost:9119 ได้
- [ ] Telegram bot ตอบกลับได้ (ถ้าใส่ token)
- [ ] รัน `agy` ได้ (login ด้วย Google)
- [ ] ทุกโปรแกรมเรียกใช้ได้จากทุก folder (PATH ถูกต้อง)

---

## 🐛 ปัญหาที่พบบ่อย

### 1. `hermes: command not found`

**สาเหตุ:** PATH ไม่ได้ตั้ง

**แก้ไข:**
```bash
# Linux/macOS
source ~/.bashrc  # หรือ source ~/.zshrc

# Windows
# เปิด PowerShell ใหม่
```

### 2. `Permission denied` (Linux/macOS)

**สาเหตุ:** สคริปต์ไม่มีสิทธิ์ execute

**แก้ไข:**
```bash
chmod +x install-linux.sh  # หรือ install-mac.sh
```

### 3. `Execution Policy` (Windows)

**สาเหตุ:** PowerShell บล็อกรันสคริปต์

**แก้ไข:**
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4. Internet Connection

**สาเหตุ:** ไม่สามารถดาวน์โหลด packages ได้

**แก้ไข:**
- ตรวจสอบการเชื่อมต่อ Internet
- ถ้าใช้ corporate proxy อาจต้องตั้งค่า proxy

### 5. `agy: command not found`

**สาเหตุ:** PATH ไม่ได้ตั้ง หรือยังไม่ได้ login

**แก้ไข:**
```bash
# Linux/macOS
source ~/.bashrc

# Windows
# เปิด PowerShell ใหม่

# Login ครั้งแรก
agy
```

---

## 📞 ต้องการความช่วยเหลือ?

ถ้ามีปัญหาในการติดตั้ง:
1. อ่าน `TESTING_GUIDE.md` เพื่อตรวจสอบการติดตั้ง
2. ส่ง screenshot ของ error มาให้ instructor

---

**สร้างโดย:** Hermes Agent Training Team  
**อัพเดทล่าสุด:** 2026-07-11  
**เวอร์ชัน:** 1.1
