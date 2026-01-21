@echo off
title NEXUS PROTOCOL - Master Launcher (Phase 1.3.1)
color 0b
cd /d "%~dp0"

echo ====================================================
echo             NEXUS PROTOCOL: SOVEREIGN NODE
echo             PHASE 1.3.1 - GRANT SIMULATION
echo ====================================================
echo.

:: 1. IDENTITY SWITCHBOARD
echo [Step 1] Identity Switchboard Configuration
echo ----------------------------------------------------
echo [MODE] 1. DUMMY (Sovereign Simulation - RECOMMENDED)
echo [MODE] 2. TON   (Mainnet Bridge - Requires BOT_TOKEN)
echo.
set /p mode="Select Execution Mode [1/2]: "

if "%mode%"=="2" (
    if "%TELEGRAM_BOT_TOKEN%"=="" (
        echo [WARN] No Bot Token detected. 
        echo [INFO] Pivoting to SOVEREIGN_SIMULATION...
        set "CHAIN_ADAPTER=dummy"
    ) else (
        set "CHAIN_ADAPTER=ton"
    )
) else (
    set "CHAIN_ADAPTER=dummy"
)

:: 2. NGROK SOVEREIGN BRIDGE
echo.
echo [Step 2] Calibrating External Bridge (Ngrok)...
set /p launch_ngrok="Launch Ngrok Tunnel for Mobile/Telegram? (y/n): "
if /i "%launch_ngrok%"=="y" (
    echo [INFO] Starting Bridge on Port 8000...
    start "NEXUS_BRIDGE" cmd /c "ngrok http 8000 --host-header=rewrite"
    timeout /t 3 /nobreak > nul
    echo [OK] Bridge Active. Check http://127.0.0.1:4040 for your public URL.
)

:: 3. BRAIN IGNITION
echo.
echo [Step 3] Igniting Nexus Brain (The Ledger)...
:: Logic: We use /min to keep the desktop clean, or remove /min to see raw logs.
start "NEXUS_BRAIN" cmd /k "set PYTHONPATH=%~dp0&& set CHAIN_ADAPTER=%CHAIN_ADAPTER%&& set PHASE_DEV=true&& python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000"

:: 4. BODY AWAKENING
echo.
echo [Step 4] Awakening Nexus Body (The Surface)...
timeout /t 5 /nobreak > nul
set /p launch_ui="Launch Flutter Web UI? (y/n): "
if /i "%launch_ui%"=="y" (
    echo [INFO] Compiling Sovereign UI...
    start "NEXUS_BODY" cmd /k "cd /d %~dp0client && flutter run -d chrome --web-port 8080 --dart-define=NEXUS_DEV=true --dart-define=CHAIN_MODE=%CHAIN_ADAPTER%"
)

echo.
echo ====================================================
echo [STATUS] ALL SYSTEMS OPERATIONAL
echo [INFO] Running in PHASE 1.3.1 HARDENED MODE
echo ====================================================
echo Press any key to initiate Emergency Shutdown...
pause > nul
call stop_nexus.bat