@echo off
:: Set a unique title that DOES NOT start with NEXUS_ to avoid self-killing
title SHUTDOWN_EXECUTOR_CORE
setlocal enabledelayedexpansion
color 0c

echo ====================================================
echo    N E X U S   P R O T O C O L   S H U T D O W N
echo ====================================================

echo [1/6] Halting Docker Containers...
:: We let this output to console so you know when it's safe to close
docker-compose down

echo.
echo [2/6] Flushing Vault WAL to Disk (Safety Anchor)...
if exist "backend\nexus_vault.db" (
    :: Merges temporary database logs into the main file. 
    :: Note: Using backslashes for Windows pathing in the python string.
    python -c "import sqlite3; c=sqlite3.connect(r'backend\nexus_vault.db'); c.execute('PRAGMA wal_checkpoint(FULL);'); c.close();" >nul 2>&1
    echo [OK] Ledger State Anchored.
)

echo [3/6] Releasing Port 8000 (Precision Kill)...
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :8000 ^| findstr LISTENING') do (
    taskkill /F /PID %%i /T >nul 2>&1
)

echo [4/6] Closing Named Nexus Terminals...
:: Kill specific windows used in the v1.4.7 launcher
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRAIN*" /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq NEXUS_LOGS*" /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq NEXUS_MASTER_CONTROLLER*" /T >nul 2>&1

echo [5/6] Cleaning Orphaned Nexus Shells...
:: Catch-all for any other window with NEXUS in the title
taskkill /F /IM cmd.exe /FI "WINDOWTITLE eq NEXUS*" /T >nul 2>&1

echo [6/6] Terminating Bridges...
taskkill /F /IM ngrok.exe /T >nul 2>&1
taskkill /F /IM cloudflared.exe /T >nul 2>&1

echo.
echo [OK] ALL SYSTEMS OFFLINE.
timeout /t 2
exit