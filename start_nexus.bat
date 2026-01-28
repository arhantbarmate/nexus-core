@echo off
setlocal enabledelayedexpansion

:: ====================================================
:: NEXUS PROTOCOL - SOVEREIGN NODE CONTROLLER (v1.4.7)
:: ====================================================
:: Namespace: NEXUS_*
:: Integrity: Ghost-Folder Purge + Absolute Pathing

:: Force the Master Title for the launcher itself
title NEXUS_MASTER_CONTROLLER
color 0b
cd /d "%~dp0"

:MAIN_MENU
cls
echo.
echo  ====================================================
echo    N E X U S   P R O T O C O L   C O N T R O L L E R
echo  ====================================================
echo    DATA STREAM: ACTIVE  --  PHASE: 1.4.7
echo  ====================================================
echo.
echo  [1] IGNITE NODE (Docker Production)
echo      - Hardened production environment (Brain + Sentry).
echo.
echo  [2] DEPLOY NEW FRONTEND (Build + Copy)
echo      - Recompiles Flutter UI and injects into Brain.
echo.
echo  [3] DEV SIMULATION (Local Python)
echo      - Fast backend debugging (No Docker).
echo.
echo  [4] SYSTEM SHUTDOWN
echo      - Deterministic cleanup of all Nexus processes.
echo.
echo  ====================================================
set /p choice="SELECT COMMAND [1-4]: "

if "%choice%"=="1" goto DOCKER_START
if "%choice%"=="2" goto FULL_DEPLOY
if "%choice%"=="3" goto LOCAL_DEV
if "%choice%"=="4" goto SHUTDOWN
goto MAIN_MENU

:: ====================================================
:: [1] IGNITE NODE (DOCKER)
:: ====================================================
:DOCKER_START
echo.
echo [STEP 0] Ensuring Vault Integrity...

:: 1. DETECT AND DESTROY GHOST DIRECTORIES
:: If nexus_vault.db exists as a folder, this kills it to prevent mount errors.
if exist "backend\nexus_vault.db\" (
    echo [WARN] Found ghost directory at vault location. Purging...
    rmdir /s /q "backend\nexus_vault.db"
)

:: 2. INITIALIZE SOVEREIGN LEDGER FILE
if not exist "backend" mkdir "backend"
if not exist "backend\nexus_vault.db" (
    echo [INFO] No Vault found. Initializing Ledger File...
    type nul > "backend\nexus_vault.db"
)

echo [INFO] Waking up Sovereign Node...
:: Use -d to run in background so this window stays as a controller
docker-compose up -d

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Docker failed to ignite. Check Docker Desktop status.
    pause
    goto MAIN_MENU
)

echo [SUCCESS] System Online.
echo ----------------------------------------------------
echo [LOCAL]  http://localhost:8000
echo [PUBLIC] https://nexucore.xyz
echo ----------------------------------------------------
set /p logs="View Live Stream? (y/n): "
if /i "%logs%"=="y" start "NEXUS_LOGS" docker-compose logs -f
goto MAIN_MENU

:: ====================================================
:: [2] FULL DEPLOY
:: ====================================================
:FULL_DEPLOY
echo.
echo [STEP 1/2] Compiling Sovereign Body (Flutter)...
if not exist "client" (
    echo [ERROR] Client folder not found!
    pause
    goto MAIN_MENU
)
cd client
call flutter build web --release --base-href "/"
cd ..

echo.
echo [STEP 2/2] Injecting into Brain...
if not exist "backend\static" mkdir "backend\static"
:: Clean old build and copy new one
powershell -Command "Remove-Item -Recurse -Force backend\static\*"
xcopy /E /I /Y "client\build\web" "backend\static"

echo.
echo [DONE] Frontend updated. Restarting containers...
docker-compose up -d --build
pause
goto MAIN_MENU

:: ====================================================
:: [3] LOCAL DEV
:: ====================================================
:LOCAL_DEV
cls
echo [INFO] Entering Simulation Mode...
:: Kill any existing local brain
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRAIN*" /T >nul 2>&1

if not exist "backend\nexus_vault.db" type nul > "backend\nexus_vault.db"

echo.
echo [INFO] Igniting Python Brain (Port 8000)...
:: Launch in a new window to keep this controller active
start "NEXUS_BRAIN" cmd /k "set PYTHONPATH=%~dp0&& set NEXUS_ENV=dev&& python -m uvicorn backend.main:app --host 127.0.0.1 --port 8000 --reload"

echo.
echo [STATUS] Running Locally (Sovereign Lock).
pause
goto MAIN_MENU

:: ====================================================
:: [4] SHUTDOWN
:: ====================================================
:SHUTDOWN
if exist "stop_nexus.bat" (
    call stop_nexus.bat
) else (
    echo [WARN] stop_nexus.bat missing. Running basic shutdown...
    docker-compose down
)
exit