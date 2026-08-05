# 📋 คู่มือทดสอบการติดตั้ง Hermes Agent (Course 0)

**Version:** 1.0.0 | **Updated:** 2026-08-05 | **Platform:** Windows Only

---

##  วัตถุประสงค์

ทดสอบ Quick Install Script บน Windows เพื่อตรวจสอบว่า:
- ✅ ส่วนประกอบทั้งหมดติดตั้งสำเร็จ
- ✅ Hermes CLI, TUI, Dashboard, Desktop ใช้งานได้
- ✅ Telegram Bot ตอบกลับได้
- ✅ Auto-query 20 models จาก LiteLLM proxy
- ✅ agy (Antigravity CLI) ใช้งานได้

---

## 📦 ไฟล์ที่ต้องใช้

### สำหรับ Windows
| ไฟล์ | หน้าที่ |
|---|---|
| **`quick-install.ps1`** | PowerShell script (หลัก) |
| **`quick-install.bat`** | CMD fallback (ดับเบิลคลิก) |
| **`README.md`** | คู่มือฉบับเต็ม |

### ไฟล์ประกอบ (ถ้าต้องการดู)
| ไฟล์ | หน้าที่ |
|---|---|
| `02-hermes-setup.md` | Course Module 02 (พร้อมรูปประกอบ) |
| `INSTALLATION_GUIDE.md` | คู่มือติดตั้งฉบับละเอียด |
| `ONE_LINE_COMMANDS.md` | สรุปคำสั่ง one-liner |
| `CHANGELOG.md` | ประวัติการเปลี่ยนแปลง |

---

## 🚀 ขั้นตอนการทดสอบ

### วิธีที่ 1: PowerShell One-Liner (แนะนำ)
```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### วิธีที่ 2: CMD (สำรอง)
```cmd
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex"
```

### วิธีที่ 3: ดับเบิลคลิก
1. ดาวน์โหลด `quick-install.bat` จาก repo
2. ดับเบิลคลิกเพื่อรัน

---

## 📝 สิ่งที่สคริปต์จะทำ

| ขั้นตอน | รายละเอียด |
|---|---|
| 1. **ตรวจสอบ Prerequisites** | PowerShell 5.1+, Internet |
| 2. **ติดตั้ง Git** | Portable Git v2.47.1+ (ถ้ายังไม่มี) |
| 3. **ติดตั้ง Node.js** | v22.14.0+ portable (ถ้ายังไม่มี) |
| 4. **ติดตั้ง Python** | 3.11.9 embeddable (ถ้ายังไม่มี) |
| 5. **ติดตั้ง uv** | Python package manager |
| 6. **ติดตั้ง Hermes Agent** | ผ่าน `uv pip install -e '.[all]'` + npm build |
| 7. **ติดตั้ง Antigravity CLI (agy)** | Gemini CLI สำหรับซ่อม hermes |
| 8. **ถามข้อมูลผู้ใช้** | LiteLLM API Key, Telegram Bot Token, Telegram Chat ID |
| 9. **Auto-query 20 models** | Query จาก LiteLLM proxy หลังใส่ API key |
| 10. **ตั้งค่า Config** | เขียน `.env` และ `config.yaml` พร้อม 20 models ที่ `%LOCALAPPDATA%\hermes\` |
| 11. **ตั้ง Auto-start** | Windows Task Scheduler (Gateway 30s, Dashboard 60s) |
| 12. **เริ่ม Gateway** | Telegram Gateway ทำงานทันทีหลังติดตั้ง |

---

## ✅ Checklist ทดสอบหลังติดตั้ง

### Core Functions
- [ ] `hermes --version` แสดง version (v0.20.0)
- [ ] `hermes` เปิด CLI ได้
- [ ] ส่งข้อความ "สวัสดี" แล้วได้รับคำตอบ
- [ ] `hermes doctor` ไม่ error
- [ ] `hermes model` แสดง 20 models ที่พร้อมใช้

### TUI (Terminal UI)
- [ ] `hermes --tui` เปิด TUI interface ได้
- [ ] TUI แสดง panels และ navigation ได้

### Dashboard & Desktop
- [ ] `hermes dashboard` เปิดได้ที่ http://localhost:9119
- [ ] Dashboard แสดง Sessions, Models, Config pages
- [ ] Model dropdown แสดง 20 models
- [ ] `hermes desktop` เปิด Electron app ได้
- [ ] Desktop แสดงหน้าต่างพร้อม chat interface

### Telegram
- [ ] Telegram bot ตอบกลับข้อความ
- [ ] ส่ง `/model` แล้วเห็นปุ่มเลือก 20 models
- [ ] เลือก model แล้วเปลี่ยนได้

### Antigravity CLI
- [ ] `agy` รันได้
- [ ] ครั้งแรกต้อง login ด้วย Google Account
- [ ] `agy doctor` ตรวจสอบปัญหาได้

### Auto-start
- [ ] Restart เครื่องแล้ว Gateway ทำงานอัตโนมัติ
- [ ] Restart เครื่องแล้ว Dashboard ทำงานอัตโนมัติ
- [ ] ตรวจสอบ Task Scheduler: `schtasks /Query /TN "HermesGateway"`

### Config Files
- [ ] `%LOCALAPPDATA%\hermes\.env` มี API key
- [ ] `%LOCALAPPDATA%\hermes\config.yaml` มี 20 models ใน providers.litellm.models

---

## 🔑 ใส่ API Key ทีหลัง (ถ้าข้ามตอนติดตั้ง)

หากกด Enter ข้ามขั้นตอนใส่ API Key ตอนติดตั้ง:

### วิธีที่ 1: Interactive Wizard (แนะนำ)
```powershell
hermes model
```
เลือก provider → ใส่ base_url → ใส่ API key

### วิธีที่ 2: แก้ไขไฟล์ .env โดยตรง
```powershell
notepad $env:LOCALAPPDATA\hermes\.env
```
เพิ่ม/แก้ไข: `LITELLM_API_KEY=your-key-here`

### วิธีที่ 3: ใช้ hermes config set
```powershell
hermes config set model.api_key "your-api-key-here"
```

### ⚠️ หลังใส่ key แล้ว ต้อง restart
```powershell
hermes gateway restart
hermes chat -q "สวัสดี"   # ทดสอบ
```

---

## 🐛 ปัญหาที่อาจเจอ

### 1. "cannot be loaded because running scripts is disabled"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. "hermes is not recognized"
```powershell
# เปิด PowerShell ใหม่ (ให้ PATH อัปเดต)
# หรือใช้ path เต็ม:
& "$env:LOCALAPPDATA\hermes\hermes-agent\venv\Scripts\hermes.exe"
```

### 3. "git is not recognized"
```powershell
$env:Path = "$env:USERPROFILE\.local\git\bin;$env:USERPROFILE\.local\git\cmd;$env:Path"
```

### 4. "node is not recognized"
```powershell
$env:Path = "$env:USERPROFILE\.local\node;$env:Path"
```

### 5. "python is not recognized"
```powershell
$env:Path = "$env:USERPROFILE\.local\python;$env:Path"
```

### 6. Dashboard / Desktop ไม่ทำงาน
**สาเหตุ:** Antivirus บล็อก npm ตอนติดตั้ง

**วิธีแก้:**
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm install --no-fund --no-audit
npm run build -w web
```
แล้วรัน `hermes dashboard` หรือ `hermes desktop` อีกครั้ง

### 7. Telegram Bot ไม่ตอบกลับ
```powershell
# ตรวจสอบว่า Gateway ทำงานอยู่
Get-Process -Name pythonw

# ถ้าไม่ทำงาน ให้ start ใหม่
hermes gateway start

# ดู log
type $env:LOCALAPPDATA\hermes\logs\gateway.log
```

### 8. Services ไม่เริ่มหลัง Restart
```powershell
# ตรวจสอบ Task Scheduler
schtasks /Query /TN "HermesGateway"
schtasks /Query /TN "HermesDashboard"

# ถ้าไม่มี ให้ start ด้วยตนเอง
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

### 9. Desktop แสดง errors ตอนเปิดครั้งแรก
**Warnings ปกติ (ไม่กระทบ):**
- `[DIRTY] from local` — Git working tree ไม่ clean ตอน build
- `registry key not found` — Windows registry lookup สำหรับ optional feature
- `WSL is not installed` — Hermes ไม่จำเป็นต้องใช้ WSL
- `Session not found (404)` — Race condition ตอน startup, หายเองหลัง retry

**ตรวจสอบเพิ่มเฉพาะเมื่อ:** หน้าต่าง Desktop ไม่เปิด หรือแสดงหน้าจอว่างหลัง startup

### 10. Internet / Proxy Issues
- ตรวจสอบ firewall
- ถ้าใช้ corporate proxy อาจต้องตั้งค่า proxy ใน PowerShell

---

## 📊 รายงานผลทดสอบ

หลังทดสอบเสร็จ ให้บันทึกรายงานดังนี้:

### ข้อมูลระบบ
| รายการ | ค่า |
|---|---|
| Windows version | (เช่น Windows 10/11, 22H2) |
| PowerShell version | (`$PSVersionTable.PSVersion`) |
| มี admin rights ไหม | (ใช่/ไม่ใช่) |
| ใช้ corporate network ไหม | (ใช่/ไม่ใช่) |
| ปิด Antivirus ตอนติดตั้ง | (ใช่/ไม่ใช่) |

### ผลการติดตั้ง
| ขั้นตอน | สถานะ | หมายเหตุ |
|---|---|---|
| Git | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Node.js | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Python | ✅ สำเร็จ / ❌ ล้มเหลว | |
| uv | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Hermes Agent | ✅ สำเร็จ / ❌ ล้มเหลว | |
| agy | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Auto-query models (20 ตัว) | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Config | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Auto-start | ✅ สำเร็จ / ❌ ล้มเหลว | |

### ผลการทดสอบฟีเจอร์
| ฟีเจอร์ | สถานะ | หมายเหตุ |
|---|---|---|
| Hermes CLI | ✅ / ❌ | |
| Hermes TUI | ✅ / ❌ | |
| Hermes Dashboard | ✅ / ❌ | |
| Hermes Desktop | ✅ / ❌ | |
| Telegram Bot | ✅ / ❌ | |
| Telegram /model (20 models) | ✅ / ❌ | |
| agy | ✅ / ❌ | |

### ปัญหาที่เจอ
1. ___
2. ___
3. ___

### คำแนะนำ
- ___

---

##  ติดต่อ

ถ้าเจอปัญหา แจ้งผู้สอนผ่านช่องทางที่กำหนดใน Course 0 หรือเปิด [GitHub Issue](https://github.com/pbseiya/hermes-windows-test/issues)

ขอบคุณครับ! 
