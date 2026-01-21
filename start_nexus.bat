@echo off
:: Copyright 2026 Nexus Protocol Authors
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

set NEXUS_PHASE=1.3.1
title NEXUS PROTOCOL - Master Launcher (Phase %NEXUS_PHASE%)
color 0b
cd /d "%~dp0"

echo ====================================================
echo             NEXUS PROTOCOL: SOVEREIGN NODE
echo             PHASE %NEXUS_PHASE% - HARDENED GATEWAY
echo ====================================================
echo.

:: 0. PORT GUARD (Hardened: Title + Port-Based Cleansing)
echo [Step 0] Cleansing Port 8000 (Brain) and 8080 (Body)...
taskkill /FI "WINDOWTITLE eq NEXUS_BRAIN*" /F >nul 2>&1
taskkill /FI "WINDOWTITLE eq NEXUS_BODY*" /F >nul 2>&1

:: Fallback: Direct PID termination for stubborn zombie processes
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1

:: 1. IDENTITY SWITCHBOARD
echo [Step 1] Identity Switchboard Configuration
echo ----------------------------------------------------
echo [MODE] 1. DUMMY (Sovereign Simulation - RECOMMENDED)
echo [MODE] 2. TON   (Mainnet Bridge - Requires TELEGRAM_BOT_TOKEN)
echo.
set /p mode="Select Execution Mode [1/2]: "

if "%mode%"=="2" (
    if "%TELEGRAM_BOT_TOKEN%"=="" (
        echo [WARN] No Bot Token detected in environment. 
        echo [INFO] Pivoting to SOVEREIGN_SIMULATION...
        set "CHAIN_ADAPTER=dummy"
    ) else (
        set "CHAIN_ADAPTER=ton"
    )
) else (
    set "CHAIN_ADAPTER=dummy"
)

:: 2. NGROK SOVEREIGN BRIDGE (Cross-Device Tunneling)
echo.
echo [Step 2] Calibrating External Bridge (Ngrok)...
set "NGROK_URL=http://localhost:8000"
set /p launch_ngrok="Launch Ngrok Tunnel for Mobile? (y/n): "
if /i "%launch_ngrok%"=="y" (
    echo [INFO] Starting Bridge...
    start "NEXUS_BRIDGE" cmd /c "ngrok http 8000 --host-header=rewrite"
    echo [IMPORTANT] Find your Forwarding URL (e.g., https://xyz.ngrok-free.app)
    echo [IMPORTANT] at http://127.0.0.1:4040
    set /p NGROK_URL="Enter your Ngrok Public URL (Include https://): "
    
    :: Boundary Check: Ensure URL is valid for Mobile Handshake
    if not "%NGROK_URL:~0,8%"=="https://" (
        echo [ERROR] Invalid Ngrok URL. Must begin with https://
        pause
        exit /b 1
    )
)

:: 3. BRAIN IGNITION (FastAPI Ledger)
echo.
echo [Step 3] Igniting Nexus Brain (The Ledger)...
set "PHASE_DEV=true"
set "NEXUS_ENV=dev"
echo [ENV] CHAIN_ADAPTER=%CHAIN_ADAPTER% ^| ENV=%NEXUS_ENV% ^| DEV_MODE=%PHASE_DEV%

:: Logic: Gate reload behind PHASE_DEV for deterministic ledger testing
set "UVICORN_FLAGS="
if "%PHASE_DEV%"=="true" (set "UVICORN_FLAGS=--reload")

start "NEXUS_BRAIN" cmd /k "set PYTHONPATH=%~dp0&& python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000 %UVICORN_FLAGS%"

:: 4. BODY AWAKENING (Flutter Surface)
echo.
echo [Step 4] Awakening Nexus Body (The Surface)...
timeout /t 3 /nobreak > nul
set /p launch_ui="Launch Flutter Web UI? (y/n): "
if /i "%launch_ui%"=="y" (
    echo [INFO] Injecting Armed API URL: %NGROK_URL%
    if not exist "%~dp0client" (
        echo [ERROR] Client directory not found.
        goto :shutdown_prompt
    )
    cd /d "%~dp0client"
    start "NEXUS_BODY" cmd /k "flutter run -d chrome --web-port 8080 --dart-define=NEXUS_API_URL=%NGROK_URL%/api --dart-define=NEXUS_DEV=true --dart-define=CHAIN_MODE=%CHAIN_ADAPTER%"
)

:shutdown_prompt
echo.
echo ====================================================
echo [STATUS] ALL SYSTEMS OPERATIONAL (PHASE %NEXUS_PHASE%)
echo [REMOTE] API_ENDPOINT: %NGROK_URL%/api
echo ====================================================
echo Press any key to initiate Emergency Shutdown...
pause > nul

:: 5. EMERGENCY SHUTDOWN
echo [EMERGENCY] Terminating all Nexus surfaces and ledgers...
if exist "%~dp0stop_nexus.bat" (
    call "%~dp0stop_nexus.bat"
) else (
    taskkill /FI "WINDOWTITLE eq NEXUS_*" /F >nul 2>&1
)