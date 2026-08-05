# v1.0.0 - Hermes Agent v0.20.0 Windows Installer

**Release Date:** 2026-08-05  
**Hermes Agent Version:** v0.20.0 (2026.8.3)  
**Platform:** Windows 10/11 (64-bit)

---

## 🎯 ภาพรวม

Installation script สำหรับติดตั้ง **Hermes Agent** บน Windows แบบ **user-space** (ไม่ต้องใช้ admin rights) พร้อมฟีเจอร์ auto-query models จาก LiteLLM proxy

---

## ✨ ฟีเจอร์

### การติดตั้ง
- ✅ **No Admin Required** - ติดตั้งใน user folder ทั้งหมด
- ✅ **Auto-install Prerequisites** - Git, Node.js v22, Python 3.11, uv
- ✅ **Full UI Support** - Dashboard, Desktop, TUI
- ✅ **Antivirus-friendly** - Retry mechanism 5 ครั้งพร้อม delay

### Hermes Agent
- ✅ **Auto-query 20 Models** - Query จาก LiteLLM proxy อัตโนมัติ
- ✅ **LiteLLM Proxy Support** - รองรับ custom proxy
- ✅ **Telegram Gateway** - Messaging platform
- ✅ **Web Dashboard** - http://localhost:9119
- ✅ **Desktop App** - Electron-based
- ✅ **Auto-start** - Task Scheduler หลัง reboot

### Models ที่รองรับ (20 models)
```
qwen3.7-plus, qwen3.6-plus, qwen3.5-plus
glm-5, glm-4.7
kimi-k2.5, MiniMax-M2.5
qwen3-coder-plus, qwen3-coder-next, qwen3-max-2026-01-23
anthropic/qwen3.7-plus, anthropic/qwen3.6-plus, anthropic/qwen3.5-plus
anthropic/glm-5, anthropic/glm-4.7, anthropic/kimi-k2.5
anthropic/MiniMax-M2.5, anthropic/qwen3-coder-plus
anthropic/qwen3-coder-next, anthropic/qwen3-max-2026-01-23
```

---

## 🚀 วิธีติดตั้ง

### One-Line Command (แนะนำ)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### ขั้นตอนการติดตั้ง
1. **ปิด Antivirus** ชั่วคราว (Trend Micro, Windows Defender)
2. **เปิด PowerShell** (ไม่ต้อง run as admin)
3. **รัน one-line command** ด้านบน
4. **ใส่ credentials** เมื่อถูกถาม:
   - LiteLLM API Key
   - Telegram Bot Token (optional)
   - Telegram Chat ID (optional)
5. **รอ 10-20 นาที** (npm install ใช้เวลานานสุด)
6. **เปิด Antivirus** กลับมา

---

##  Credentials ที่ต้องใช้

### 1. LiteLLM API Key
- ได้รับจาก instructor (Course 0)
- ใช้กับ LiteLLM Proxy: `https://litellm-proxy-gateway.pbseiyacpro7.workers.dev/v1`

### 2. Telegram Bot Token (optional)
- สร้างผ่าน [@BotFather](https://t.me/BotFather) ใน Telegram
- ส่ง `/newbot` และทำตามขั้นตอน
- Token format: `123456789:ABCdefGHI...`

### 3. Telegram Chat ID (optional)
- เปิด Telegram → ค้นหา `@userinfobot`
- ส่ง `/start` → จะได้ Chat ID (ตัวเลข)
- ใช้เพื่อจำกัดสิทธิ์ให้เฉพาะคุณใช้ bot ได้

---

## 📋 ข้อกำหนดระบบ

| รายการ | ข้อกำหนด |
|---|---|
| **OS** | Windows 10/11 (64-bit) |
| **PowerShell** | 5.1 หรือสูงกว่า |
| **Internet** | จำเป็น (ดาวน์โหลด packages) |
| **Admin Rights** | ไม่จำเป็น |
| **Antivirus** | ปิดชั่วคราวตอนติดตั้ง |
| **Disk Space** | ~2-3 GB (หลังติดตั้ง) |

---

##  การทดสอบหลังติดตั้ง

### Core Functions
```powershell
hermes --version              # เช็ค version
hermes                        # เปิด CLI chat
hermes doctor                 # Diagnose problems
hermes model                  # เปลี่ยน model (20 options)
```

### Dashboard & Desktop
```powershell
hermes dashboard              # เปิด web UI (http://localhost:9119)
hermes desktop                # เปิด Electron app
```

### Telegram
- ส่งข้อความหา bot → ต้องได้รับคำตอบ
- ใช้ `/model` → ต้องเห็น 20 models

### Auto-start
- Restart เครื่อง → Gateway และ Dashboard ต้อง start อัตโนมัติ

---

## 🛠️ Troubleshooting

### Dashboard/Desktop ไม่ทำงาน
**สาเหตุ:** Antivirus บล็อก npm ตอนติดตั้ง

**วิธีแก้:**
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm run build -w web
hermes dashboard
```

### Telegram Bot ไม่ตอบกลับ
```powershell
hermes gateway start
type $env:LOCALAPPDATA\hermes\logs\gateway.log
```

### hermes command not found
- เปิด PowerShell ใหม่ (ให้ PATH อัปเดต)
- หรือใช้ full path: `& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"`

---

## 📦 ไฟล์ใน Release

| ไฟล์ | รายละเอียด |
|---|---|
| `quick-install.ps1` | PowerShell installation script (หลัก) |
| `quick-install.bat` | CMD wrapper (double-click) |
| `quick-uninstall.ps1` | Uninstallation script |
| `README.md` | คู่มือฉบับเต็ม |
| `INSTALLATION_GUIDE.md` | Installation guide ละเอียด |
| `TESTING_GUIDE.md` | Testing procedures |
| `ONE_LINE_COMMANDS.md` | Quick reference |

---

## 🔐 Security Notes

- ✅ ไม่มี credentials ใน code
- ✅ Credentials เก็บใน `%LOCALAPPDATA%\hermes\.env` (ไม่ commit)
- ✅ Config เก็บใน `%LOCALAPPDATA%\hermes\config.yaml` (ไม่ commit)
- ✅ .gitignore ป้องกัน credentials leak

---

## 📞 Support

- **Issues:** https://github.com/pbseiya/hermes-windows-test/issues
- **Course:** Course 0 - Hermes + AI Harness

---

## 📝 Changelog

### v1.0.0 (2026-08-05)
- ✅ Initial stable release
- ✅ Auto-query models from LiteLLM proxy (20 models)
- ✅ Full UI support (Dashboard, Desktop, TUI)
- ✅ Antivirus-friendly installation (5 retries)
- ✅ Auto-start via Task Scheduler
- ✅ Telegram Gateway integration
- ✅ Complete uninstall support (~2 min)

---

**Happy installing! 🎉**
