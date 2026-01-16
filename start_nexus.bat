@echo off
title NEXUS PROTOCOL - Master Launcher
color 0b

echo ====================================================
echo        NEXUS PROTOCOL: SOVEREIGN NODE V1.1
echo ====================================================
echo.

:: 0. CRITICAL REPAIR: Install Missing Proxy Library
echo [0/3] 🛠️  Installing 'httpx' for Gateway Proxy...
pip install httpx uvicorn fastapi python-dotenv > nul 2>&1

:: 1. Start the Brain (The Gateway)
echo [1/3] 🧠 Starting Nexus Gateway on Port 8000...
:: We use cmd /k so the window STAYS OPEN if there is an error
start "NEXUS_BRAIN" cmd /k "cd backend && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"

:: Give the Brain more time to initialize
timeout /t 5 /nobreak > nul

:: 2. Start the Body (Flutter Web Server)
echo [2/3] 👕 Starting Nexus Body on Port 8080...
start "NEXUS_BODY" cmd /k "cd client && flutter run -d web-server --web-port 8080 --release --web-hostname 0.0.0.0"

echo ⏳ Connecting Neural Pathways...
timeout /t 10 /nobreak > nul

:: 3. LAUNCH CHROME (Targeting the Gateway)
start chrome http://localhost:8000

echo.
echo ----------------------------------------------------
echo [3/3] 📡 OPTIONAL: EXTERNAL BRIDGE (ngrok)
echo ----------------------------------------------------
set /p tunnel="Launch ngrok tunnel for Telegram Mobile access? (y/n): "

:: --- FIXED NGROK SECTION START ---
:: We use 'goto' instead of parentheses to prevent parser crashes
if /i "%tunnel%"=="y" goto LAUNCH_NGROK
goto END

:LAUNCH_NGROK
echo 🔗 Initializing Bridge (Brain-First Mode)...
start "NEXUS_BRIDGE" cmd /k "ngrok http 8000 || echo ❌ NGROK ERROR: Check if ngrok.exe is in this folder or PATH. && pause"

:END
:: --- FIXED NGROK SECTION END ---

echo ====================================================
echo ✅ SYSTEM INITIALIZED (Gateway: Port 8000)
echo ====================================================
pause