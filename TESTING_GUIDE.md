# 📧 คู่มือทดสอบการติดตั้ง Hermes Agent

## ผู้ทดสอบ
- pbseiya@gmail.com
- pongsak.b@irpc.co.th

## 🎯 วัตถุประสงค์
ทดสอบ Quick Install Script บน Windows เพื่อหาปัญหาที่อาจเกิดขึ้น

---

## 📦 ไฟล์ที่ต้องใช้

### สำหรับ Windows
1. **quick-install.ps1** — PowerShell script (หลัก)
2. **quick-install.bat** — CMD fallback (สำรอง)
3. **README.md** — คู่มือฉบับเต็ม

### ไฟล์เพิ่มเติม (ถ้าต้องการดู)
- `02-hermes-setup.html` — Slides แบบ HTML (copy commands ได้)
- `02-hermes-setup.pdf` — Slides แบบ PDF

---

## 🚀 ขั้นตอนการทดสอบ

### วิธีที่ 1: PowerShell (แนะนำ)

```powershell
# 1. เปิด PowerShell
# กด Win + X → เลือก "Windows PowerShell" หรือ "Terminal"

# 2. ตั้งค่า execution policy (ครั้งแรกเท่านั้น)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. ไปที่โฟลเดอร์ที่มีสคริปต์
cd Downloads
# หรือ cd ที่ที่คุณเก็บไฟล์

# 4. รันสคริปต์
.\quick-install.ps1
```

### วิธีที่ 2: CMD (สำรอง)

```cmd
:: ดับเบิลคลิก quick-install.bat
:: หรือรันจาก CMD
quick-install.bat
```

---

## 📝 สิ่งที่สคริปต์จะทำ

1. **ตรวจสอบ Prerequisites**
   - Git (ถ้าไม่มี → ติดตั้ง Portable Git)
   - Node.js v22+ (ถ้าไม่มี → ติดตั้ง portable/nvm)
   - Python 3.11+ (ถ้าไม่มี → ติดตั้ง embeddable)

2. **ติดตั้ง Hermes Agent**
   - ใช้ npm ติดตั้งใน user-space (`~/.npm-global/`)
   - ไม่ต้อง admin rights

3. **ติดตั้ง Antigravity CLI (agy)**
   - ฟรี ใช้ Google Account
   - ไม่ต้องถาม password
   - สำหรับซ่อม hermes ถ้ามีปัญหา

4. **ถาม API Keys**
   - OpenRouter API Key (ข้ามได้)
   - Telegram Bot Token (สร้างจาก @BotFather)

5. **ตั้งค่า Hermes**
   - ใช้ LiteLLM Proxy (qwen3.7-plus)
   - Dashboard ที่ http://localhost:9119
   - Auto-start หลังรีสตาร์ท

---

## ✅ Checklist ทดสอบ

หลังติดตั้งเสร็จ ให้ตรวจสอบ:

- [ ] `hermes --version` ทำงานได้
- [ ] `hermes` เปิด CLI ได้
- [ ] ส่งข้อความ "สวัสดี" ได้
- [ ] `hermes doctor` ไม่ error
- [ ] Dashboard เปิดได้ที่ http://localhost:9119
- [ ] Telegram bot ตอบกลับได้ (ถ้าใส่ token)
- [ ] `agy` ทำงานได้ (login ด้วย Google)

---

## 🐛 ปัญหาที่อาจเจอ

### 1. "cannot be loaded because running scripts is disabled"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. "hermes is not recognized"
```powershell
# เปิด PowerShell ใหม่
# หรือใช้ path เต็ม
& "$env:USERPROFILE\.npm-global\hermes.cmd"
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
$env:Path = "$env:USERPROFILE\.local\python;$env:USERPROFILE\.local\python\Scripts;$env:Path"
```

### 6. Internet/Proxy Issues
- ตรวจสอบ firewall
- ถ้าใช้ corporate proxy อาจต้องตั้งค่า proxy

---

## 📊 รายงานผลทดสอบ

หลังทดสอบเสร็จ กรุณารายงาน:

### ข้อมูลระบบ
- Windows version: (เช่น Windows 10/11, 22H2)
- PowerShell version: (`$PSVersionTable.PSVersion`)
- มี admin rights ไหม: (ใช่/ไม่ใช่)
- ใช้ corporate network ไหม: (ใช่/ไม่ใช่)

### ผลการติดตั้ง
- [ ] Step 1 (Git) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 2 (Node.js) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 3 (Python) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 4 (Hermes) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 5 (agy) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 6 (Config) สำเร็จ/ล้มเหลว — หมายเหตุ: ___
- [ ] Step 7 (Auto-start) สำเร็จ/ล้มเหลว — หมายเหตุ: ___

### ปัญหาที่เจอ
1. ___
2. ___
3. ___

### คำแนะนำ
- ___

---

## 📞 ติดต่อ

ถ้าเจอปัญหา ส่งรายงานกลับมาที่:
- Telegram: @seiya_hermes
- Email: pbseiya@gmail.com

ขอบคุณครับ! 🙏
