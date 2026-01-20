@echo off
title NEXUS PROTOCOL - Master Launcher (Hardened)
color 0b

:: Ensure we are working from the project root
cd /d "%~dp0"

echo ====================================================
echo          NEXUS PROTOCOL: SOVEREIGN NODE V1.3.1
echo ====================================================
echo.

:: 1. CREDENTIAL LOADER
set "PYTHONPATH=%~dp0"

if exist "backend\.env" (
    echo ✅ .env detected. Loading Sovereign Credentials...
    for /f "usebackq tokens=*" %%i in ("backend\.env") do set "%%i"
) else (
    echo ⚠️ WARNING: No .env found. Sentry Guard may fail.
)

:: 2. IDENTITY SWITCHBOARD (Hardened)
echo [Step 1] Identity Switchboard Configuration
echo ----------------------------------------------------
echo OPTIONS:
echo [ton]   - Enforce Telegram HMAC Security (Fail-Closed)
echo [dummy] - Allow Mock Signatures (Dev/Test Only)
echo [skip]  - Use adapter defined in .env (Default)
echo ----------------------------------------------------
set /p mode="Select Active Adapter: "

:: Logic Processor
if /i "%mode%"=="skip" (
    echo 🧹 Reverting to .env defaults...
    set "CHAIN_ADAPTER="
) else if /i "%mode%"=="ton" (
    set "CHAIN_ADAPTER=ton"
) else if /i "%mode%"=="dummy" (
    set "CHAIN_ADAPTER=dummy"
) else (
    echo ℹ️ No selection made. Falling back to .env...
    set "CHAIN_ADAPTER="
)

:: FAIL-FAST IDENTITY GUARD
if /i "%CHAIN_ADAPTER%"=="ton" (
    if "%TELEGRAM_BOT_TOKEN%"=="" (
        echo.
        echo ❌ FATAL ERROR: Adapter set to 'ton' but TELEGRAM_BOT_TOKEN is missing.
        echo.
        pause
        exit /b 1
    )
)

:: Echo final state for auditor visibility
if "%CHAIN_ADAPTER%"=="" (
    echo 🔐 Active Adapter: .env DEFAULT
) else (
    echo 🔐 Active Adapter: %CHAIN_ADAPTER%
)

if "%NEXUS_ENV%"=="" set "NEXUS_ENV=dev"

:: 3. BRAIN IGNITION (Gateway)
echo.
echo [Step 2] 🧠 Igniting Hardened Nexus Brain...
start "NEXUS_BRAIN" cmd /k "set "PYTHONPATH=%~dp0" && uvicorn backend.main:app --host 0.0.0.0 --port 8000 --reload"

timeout /t 5 /nobreak > nul

:: 4. BODY IGNITION (Flutter - Force Chrome & Dev Sync)
echo [Step 3] 👕 Attaching Nexus Body...

:: 🛡️ HARD-SYNC: We force the flag here to ensure the UI sends 'valid_mock_signature'
:: This is the ONLY way to bypass "Unauthorised Session" in local Chrome tests.
set "FORCE_DEV=--dart-define=NEXUS_DEV=true"

echo 🚀 Launching Chrome with Gateway Handshake Armed...

:: We pass the flag directly into the command string to prevent expansion lag
start "NEXUS_BODY" cmd /k "cd client && flutter run -d chrome --web-port 8080 %FORCE_DEV%"

echo ⏳ Synchronizing Multichain Handshake...
timeout /t 10 /nobreak > nul

:: 5. EXTERNAL BRIDGE (Optional)
echo.
echo ----------------------------------------------------
echo [Step 4] 📡 EXTERNAL BRIDGE (ngrok)
echo ----------------------------------------------------
set /p tunnel="Launch ngrok tunnel for Telegram Mobile access? (y/n): "

if /i "%tunnel%"=="y" (
    :: Point ngrok to 8080 (The Body) so Telegram can see the UI
    start "NEXUS_BRIDGE" cmd /k "ngrok http 8080"
    timeout /t 3 /nobreak > nul
    :: Open Inspector for fast URL retrieval
    start chrome http://127.0.0.1:4040
)

echo.
echo ====================================================
echo ✅ SYSTEM ONLINE (Phase 1.3.1 Hardened)
echo ====================================================
pause