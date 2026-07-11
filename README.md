# Hermes Agent Quick Install

คู่มือติดตั้ง Hermes Agent สำหรับผู้เรียน Course 0

---

## ⚡ ติดตั้งบรรทัดเดียวจบ (Windows)

เปิด **PowerShell** แล้วรัน:

```powershell
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

สคริปต์จะติดตั้งทุกอย่างอัตโนมัติ:
- Git, Node.js v22+, Python 3.11+, uv
- Hermes Agent (พร้อม Dashboard, TUI)
- Antigravity CLI (agy) — สำหรับซ่อม hermes ยามฉุกเฉิน

**สิ่งที่ต้องเตรียมก่อนรัน:**
1. **LiteLLM API Key** — ได้จาก instructor (Course 0)
2. **Telegram Bot Token** — สร้างจาก @BotFather ใน Telegram (ดูวิธีใน Slide Module 02)

> ไม่ต้องใช้ admin rights — ทุกอย่างติดตั้งใน user folder

---

## 🚀 หลังติดตั้งเสร็จ

```powershell
hermes                          # เริ่มสนทนากับ Hermes
hermes doctor                   # วินิจฉัยปัญหา
hermes model                    # เปลี่ยน model
```

**Dashboard:** http://localhost:9119

**เริ่ม Telegram Gateway + Dashboard อัตโนมัติหลัง login:**
```powershell
schtasks /Run /TN "HermesGateway"
schtasks /Run /TN "HermesDashboard"
```

---

## ❓ คำถามที่พบบ่อย

### Q: ต้องใช้ admin rights ไหม?
**A:** ไม่ต้อง ทุกอย่างติดตั้งใน user folder ของคุณ

### Q: ใช้เวลานานแค่ไหน?
**A:** ประมาณ 5-15 นาที ขึ้นอยู่กับความเร็ว internet

### Q: ต้อง restart เครื่องไหม?
**A:** ไม่ต้อง แต่ควรเปิด PowerShell ใหม่หลังติดตั้งเสร็จ

### Q: ติดตั้งไม่สำเร็จทำยังไง?
**A:** รันคำสั่งเดิมอีกครั้ง ถ้ายังไม่ได้ ให้ลอง:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
irm https://raw.githubusercontent.com/pbseiya/hermes-windows-test/main/quick-install.ps1 | iex
```

### Q: ใช้ agy แก้ปัญหา hermes ได้อย่างไร?
**A:** รัน `agy` แล้ว login ด้วย Google Account (ฟรี) แล้วบอกให้ agy ช่วยซ่อม hermes

---

## 📁 ไฟล์ใน Repository

| ไฟล์ | คำอธิบาย |
|------|----------|
| `quick-install.ps1` | PowerShell script สำหรับ Windows (one-liner) |
| `quick-install.bat` | Batch file สำหรับดับเบิลคลิก |
| `install-windows.bat` | สคริปต์ติดตั้งแบบเก่าสำหรับ Windows |
| `02-hermes-setup.html` | Slides (เปิดใน browser) |
| `02-hermes-setup.md` | Slides (Markdown source) |
| `INSTALLATION_GUIDE.md` | คู่มือติดตั้งฉบับเต็ม |
| `TESTING_GUIDE.md` | คู่มือทดสอบหลังติดตั้ง |

---

**สร้างโดย:** Hermes Agent Training Team
**อัพเดทล่าสุด:** 2026-07-12
