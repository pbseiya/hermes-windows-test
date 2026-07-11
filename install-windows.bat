@echo off
REM Hermes Agent Quick Install Script for Windows
REM Double-click to run

echo ============================================
echo Hermes Agent Quick Install (Windows)
echo ============================================
echo.

REM Check if PowerShell is available
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell not found
    echo Please use Windows 10 or later
    pause
    exit /b 1
)

echo This script will:
echo 1. Install Node.js v22 (if not installed)
echo 2. Install Python 3.11 (if not installed)
echo 3. Install Hermes Agent
echo 4. Ask for your OpenRouter API key
echo.
echo All installations will be in your user folder (no admin required)
echo.
pause

REM Run PowerShell script
powershell -ExecutionPolicy Bypass -File "%~dp0quick-install.ps1"

echo.
echo Installation complete!
echo.
pause
