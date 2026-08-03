# 📋 คู่มือทดสอบการติดตั้ง Hermes Agent (Course 0)

**Version:** 2.0 | **Updated:** 2026-07-24 | **Platform:** Windows Only

---

## 🎯 วัตถุประสงค์

ทดสอบ Quick Install Script บน Windows เพื่อตรวจสอบว่า:
- ✅ ส่วนประกอบทั้งหมดติดตั้งสำเร็จ
- ✅ Hermes CLI และ Gateway ใช้งานได้
- ✅ Telegram Bot ตอบกลับได้
- ✅ Dashboard และ Desktop เข้าถึงได้

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
| `02-hermes-setup.md` | Slides แบบ Markdown (source) |
| `INSTALLATION_GUIDE.md` | คู่มือติดตั้งฉบับละเอียด |
| `ONE_LINE_COMMANDS.md` | สรุปคำสั่ง one-liner |

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
| 9. **ตั้งค่า Config** | เขียน `.env` และ `config.yaml` ที่ `%LOCALAPPDATA%\hermes\` |
| 10. **ตั้ง Auto-start** | Windows Task Scheduler (Gateway 30s, Dashboard 60s) |
| 11. **เริ่ม Gateway** | Telegram Gateway ทำงานทันทีหลังติดตั้ง |

---

## ✅ Checklist ทดสอบหลังติดตั้ง

### Core Functions
- [ ] `hermes --version` แสดง version
- [ ] `hermes` เปิด CLI ได้
- [ ] ส่งข้อความ "สวัสดี" แล้วได้รับคำตอบ
- [ ] `hermes doctor` ไม่ error
- [ ] `hermes model` แสดง provider ปัจจุบัน

### Dashboard & Desktop
- [ ] `hermes dashboard` เปิดได้ที่ http://localhost:9119
- [ ] `hermes desktop` เปิด Electron app ได้

### Telegram
- [ ] Telegram bot ตอบกลับข้อความ

### Antigravity CLI
- [ ] `agy` รันได้ (ครั้งแรกต้อง login ด้วย Google Account)

### Auto-start
- [ ] Restart เครื่องแล้ว Gateway ทำงานอัตโนมัติ
- [ ] Restart เครื่องแล้ว Dashboard ทำงานอัตโนมัติ

### Config Files
- [ ] `%LOCALAPPDATA%\hermes\.env` มี API key
- [ ] `%LOCALAPPDATA%\hermes\config.yaml` มีการตั้งค่าถูกต้อง

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
1. ปิด Real-time protection ชั่วคราว
2. รันคำสั่ง:
```powershell
cd $env:LOCALAPPDATA\hermes\hermes-agent
npm run build -w web
```
3. เปิด Real-time protection กลับ
4. รัน `hermes dashboard` หรือ `hermes desktop`

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

### 9. Internet / Proxy Issues
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
| Config | ✅ สำเร็จ / ❌ ล้มเหลว | |
| Auto-start | ✅ สำเร็จ / ❌ ล้มเหลว | |

### ปัญหาที่เจอ
1. ___
2. ___
3. ___

### คำแนะนำ
- ___

---

## 📞 ติดต่อ

ถ้าเจอปัญหา แจ้งผู้สอนผ่านช่องทางที่กำหนดใน Course 0

ขอบคุณครับ! 🙏
