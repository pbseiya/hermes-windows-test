# Hermes Agent Quick Install

คู่มือติดตั้ง Hermes Agent สำหรับผู้เรียน Course 0

## 🎯 สำหรับผู้เรียนที่ไม่เคยเขียนโปรแกรม

### Windows (คอมพิวเตอร์บริษัท)

**วิธีที่ง่ายที่สุด:**
1. ดาวน์โหลดไฟล์ `hermes-windows-test-main.zip` จากปุ่ม "Code" → "Download ZIP" ด้านบน
2. แตกไฟล์ (Extract) ไปที่โฟลเดอร์ที่ต้องการ
3. ดับเบิลคลิกไฟล์ `install-windows.bat`
4. ทำตามคำแนะนำบนหน้าจอ
5. เมื่อถาม API key ให้ใส่ OpenRouter API key ของคุณ

**ถ้ามีปัญหา:**
- เปิด PowerShell แล้วรัน: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- ลองรัน `install-windows.bat` อีกครั้ง

---

### macOS

**วิธีติดตั้ง:**
1. ดาวน์โหลดไฟล์ `hermes-windows-test-main.zip`
2. แตกไฟล์
3. เปิด Terminal
4. ไปที่โฟลเดอร์ที่แตกไฟล์: `cd ~/Downloads/hermes-windows-test-main`
5. รันคำสั่ง: `chmod +x install-mac.sh`
6. รันคำสั่ง: `./install-mac.sh`
7. ทำตามคำแนะนำบนหน้าจอ

---

### Linux

**วิธีติดตั้ง:**
1. ดาวน์โหลดไฟล์ `hermes-windows-test-main.zip`
2. แตกไฟล์
3. เปิด Terminal
4. ไปที่โฟลเดอร์ที่แตกไฟล์: `cd ~/Downloads/hermes-windows-test-main`
5. รันคำสั่ง: `chmod +x install-linux.sh`
6. รันคำสั่ง: `./install-linux.sh`
7. ทำตามคำแนะนำบนหน้าจอ

---

## 📦 ไฟล์ในโฟลเดอร์

| ไฟล์ | คำอธิบาย |
|------|----------|
| `install-windows.bat` | สคริปต์ติดตั้งสำหรับ Windows (ดับเบิลคลิก) |
| `install-mac.sh` | สคริปต์ติดตั้งสำหรับ macOS |
| `install-linux.sh` | สคริปต์ติดตั้งสำหรับ Linux |
| `quick-install.ps1` | PowerShell script สำหรับ Windows |
| `quick-install.sh` | Bash script สำหรับ macOS/Linux |
| `README.md` | คู่มือฉบับเต็ม (ไฟล์นี้) |
| `TESTING_GUIDE.md` | คู่มือทดสอบหลังติดตั้ง |
| `02-hermes-setup.html` | Slides (เปิดใน browser) |
| `02-hermes-setup.pdf` | Slides (PDF) |
| `02-hermes-setup.md` | Slides (Markdown source) |

---

## 🔑 OpenRouter API Key

ก่อนติดตั้ง คุณต้องมี OpenRouter API key

**วิธีขอ API key (ฟรี):**
1. เปิด https://openrouter.ai/keys
2. ลงชื่อเข้าใช้ด้วย Google Account
3. คลิก "Create Key"
4. ตั้งชื่อ key (เช่น "Hermes Course")
5. Copy key ที่ได้ (ขึ้นต้นด้วย `sk-or-...`)

---

## ❓ คำถามที่พบบ่อย

### Q: ต้องใช้ admin rights ไหม?
**A:** ไม่ต้อง ทุกอย่างติดตั้งใน user folder ของคุณ

### Q: ถ้าติดตั้งไม่สำเร็จทำยังไง?
**A:** 
- Windows: ลองเปิด PowerShell แล้วรัน `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Mac/Linux: ตรวจสอบว่ามี internet connection

### Q: ใช้เวลานานแค่ไหน?
**A:** ประมาณ 5-10 นาที ขึ้นอยู่กับความเร็ว internet

### Q: ต้อง restart เครื่องไหม?
**A:** ไม่ต้อง แต่ควรปิด terminal แล้วเปิดใหม่หลังติดตั้งเสร็จ

---

## 📞 ต้องการความช่วยเหลือ?

ถ้ามีปัญหาในการติดตั้ง:
1. อ่าน `TESTING_GUIDE.md` เพื่อตรวจสอบการติดตั้ง
2. ส่ง screenshot ของ error มาให้ instructor

---

**สร้างโดย:** Hermes Agent Training Team  
**อัพเดทล่าสุด:** 2026-07-11
