@echo off
REM =============================================================================
REM Hermes Agent Quick Install Script
REM รองรับ: Windows (CMD fallback สำหรับคนที่ไม่ถนัด PowerShell)
REM วิธีใช้: quick-install.bat
REM =============================================================================

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║   Hermes Agent Quick Install (Windows CMD)                 ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM --- Check PowerShell availability ---
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] ไม่พบ PowerShell ในระบบ
    echo กรุณาติดตั้ง PowerShell ก่อน: https://aka.ms/powershell
    pause
    exit /b 1
)

echo [INFO] กำลังเรียก PowerShell script...
echo.

REM --- Delegate to PowerShell script ---
powershell -ExecutionPolicy Bypass -File "%~dp0quick-install.ps1"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] PowerShell script ล้มเหลว (exit code: %errorlevel%)
    echo ลองรัน PowerShell โดยตรง:
    echo   powershell -ExecutionPolicy Bypass -File quick-install.ps1
    pause
    exit /b %errorlevel%
)

echo.
echo [OK] เสร็จสมบูรณ์!
pause
