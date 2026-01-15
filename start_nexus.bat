@echo off
setlocal EnableDelayedExpansion

TITLE Nexus Protocol - Sovereign Node Launcher
COLOR 0A

echo ==================================================
echo   NEXUS PROTOCOL: STARTING SOVEREIGN NODE
echo ==================================================

:: 1. CLEANUP PREVIOUS SESSIONS
echo [1/4] Cleaning up stale Nexus processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM uvicorn.exe /T >nul 2>&1

:: 2. START BACKEND (BRAIN)
echo [2/4] Launching FastAPI Backend...
:: We use a single-line command string here to prevent "Blank Window" errors.
start "Nexus_Backend" cmd /k "cd /d C:\nexus-core\backend && if exist venv\Scripts\activate.bat (call venv\Scripts\activate) && uvicorn main:app --reload --host 127.0.0.1 --port 8000"

:: 3. VERIFICATION DELAY
echo [3/4] Initializing SQLite and Port Binding...
timeout /t 5 /nobreak >nul

:: 4. START FRONTEND (BODY)
echo [4/4] Launching Flutter Web Client...
cd /d C:\nexus-core\client
start "Nexus_Frontend" flutter run -d chrome --web-port 5000

echo.
echo ==================================================
echo   SUCCESS: Nexus Sovereign Node is booting
echo ==================================================
echo.
echo Press any key to exit this launcher window.
pause >nul
endlocal