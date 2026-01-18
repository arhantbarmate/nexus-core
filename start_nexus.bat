@echo off
title NEXUS PROTOCOL - Master Launcher (Hardened)
color 0b

echo ====================================================
echo        NEXUS PROTOCOL: SOVEREIGN NODE V1.3.1
echo ====================================================
echo.

:: 0. CRITICAL REPAIR: Install Required Libraries
echo [0/3] 🛠️  Hardening Dependencies...
:: python-multipart resolves the PendingDeprecationWarning
pip install httpx uvicorn fastapi python-dotenv python-multipart pytest > nul 2>&1

:: 1. Start the Brain (The Gateway)
echo [1/3] 🧠 Starting Hardened Nexus Brain on Port 8000...
:: Injecting PYTHONPATH allows the app to find 'sentry.py' correctly
start "NEXUS_BRAIN" cmd /k "set PYTHONPATH=%CD%\backend&& cd backend && python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"

:: Give the Brain time to initialize the SQLite Vault
timeout /t 5 /nobreak > nul

:: 2. Start the Body (Flutter Web Server)
echo [2/3] 👕 Starting Nexus Body on Port 8080...
:: FIX: Removed --web-renderer to ensure compatibility with all Flutter versions
start "NEXUS_BODY" cmd /k "cd client && flutter run -d web-server --web-port 8080 --release --web-hostname 0.0.0.0"

echo ⏳ Synchronizing Multichain Handshake...
timeout /t 10 /nobreak > nul

:: 3. LAUNCH CHROME (Targeting the Gateway Proxy)
:: We target Port 8000 because the Brain proxies the UI from Port 8080
start chrome http://localhost:8000

echo.
echo ----------------------------------------------------
echo [3/3] 📡 OPTIONAL: EXTERNAL BRIDGE (ngrok)
echo ----------------------------------------------------
set /p tunnel="Launch ngrok tunnel for Telegram Mobile access? (y/n): "

if /i "%tunnel%"=="y" goto LAUNCH_NGROK
goto END

:LAUNCH_NGROK
echo 🔗 Initializing Multichain Bridge (Brain-First Mode)...
start "NEXUS_BRIDGE" cmd /k "ngrok http 8000 || echo ❌ NGROK ERROR: Check PATH. && pause"

:END
echo ====================================================
echo ✅ SYSTEM HARDENED (v1.3.1 - Fail-Closed Active)
echo ====================================================
pause