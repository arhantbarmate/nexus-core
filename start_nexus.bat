@echo off
:: Nexus Protocol Phase 1.3.1 - Sovereign Ignition
:: This version uses the "Safe Input" pattern to prevent URL-injection crashes.

title NEXUS PROTOCOL - Master Launcher
color 0b
cd /d "%~dp0"

:: 0. PORT CLEANSE
taskkill /FI "WINDOWTITLE eq NEXUS_BRAIN*" /F >nul 2>&1

:: 1. VALIDATION
if not exist "%~dp0test_client\index.html" (
    echo [ERROR] test_client assets not found.
    pause
    exit /b 1
)

:: 2. IDENTITY
set /p mode="Select Execution Mode [1. Dummy / 2. Ton]: "
set "CHAIN_ADAPTER=dummy"
if "%mode%"=="2" if not "%TELEGRAM_BOT_TOKEN%"=="" set "CHAIN_ADAPTER=ton"

:: 3. NGROK CALIBRATION (Safe Input Pattern)
set "NGROK_URL=http://localhost:8000"
set /p launch_ngrok="Launch Ngrok Tunnel for Mobile? (y/n): "
if /i not "%launch_ngrok%"=="y" goto :BRAIN_START

echo [INFO] Starting Bridge...
start "NEXUS_BRIDGE" cmd /c "ngrok http 8000 --host-header=rewrite"
echo [IMPORTANT] Find your Forwarding URL at http://127.0.0.1:4040

:URL_INPUT
:: Disable Expansion during input to prevent parsing / or - as switches
setlocal DisableDelayedExpansion
set "RAW_URL="
set /p "RAW_URL=Enter your Ngrok Public URL (Include https://): "

:: Enable Expansion only for cleaning the string
setlocal EnableDelayedExpansion
set "NGROK_URL=!RAW_URL!"

:: Strip any accidental quotes or spaces
set "NGROK_URL=!NGROK_URL:"=!"
set "NGROK_URL=!NGROK_URL: =!"

:: Validation Check
if "!NGROK_URL:~0,8!"=="https://" (
    echo [OK] URL Calibrated: !NGROK_URL!
    :: Export the variable out of the setlocal scope
    endlocal & set "NGROK_URL=%NGROK_URL%"
    goto :BRAIN_START
) else (
    echo [ERROR] Invalid URL: "!NGROK_URL!"
    echo [RETRY] Must begin with https://
    endlocal
    goto :URL_INPUT
)

:BRAIN_START
:: 4. BRAIN IGNITION
echo.
echo [Step 4] Igniting Nexus Brain (The Ledger)...
if "%NEXUS_ENV%"=="" set "NEXUS_ENV=dev"
set "UVICORN_FLAGS="
if "%NEXUS_ENV%"=="dev" set "UVICORN_FLAGS=--reload"

start "NEXUS_BRAIN" cmd /k "set PYTHONPATH=%~dp0&& set NEXUS_ENV=%NEXUS_ENV%&& python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 %UVICORN_FLAGS%"

:shutdown_prompt
echo.
echo ====================================================
echo [STATUS] ALL SYSTEMS OPERATIONAL (PHASE 1.3.1)
echo [URL] %NGROK_URL%
echo ====================================================
echo Press any key to initiate Emergency Shutdown...
pause > nul
if exist "%~dp0stop_nexus.bat" call "%~dp0stop_nexus.bat"