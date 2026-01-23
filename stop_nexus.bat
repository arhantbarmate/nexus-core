@echo off
setlocal enabledelayedexpansion
title NEXUS PROTOCOL - Emergency Shutdown (Hardened v1.3.1)
color 0c

:: Ensure we are working from the project root
cd /d "%~dp0"

echo ====================================================
echo              NEXUS PROTOCOL: EMERGENCY SHUTDOWN
echo              PHASE 1.3.1 - DETERMINISTIC CLEANUP
echo ====================================================
echo.

:: --- 🛡️ CRITICAL: DATABASE ANCHORING (Audit 1.3.1) ---
echo [1/7] Flushing Vault WAL to Disk (Checkpointing)...
:: Logic: Prevents data loss by merging .db-wal into .db before killing Python
if exist "backend/nexus_vault.db" (
    python -c "import sqlite3; c=sqlite3.connect('backend/nexus_vault.db'); c.execute('PRAGMA wal_checkpoint(FULL);'); c.close();" >nul 2>&1
    echo [OK] Ledger State Anchored.
) else (
    echo [WARN] Vault not found at expected anchor. Skipping checkpoint.
)

echo [2/7] Authoritative Port Release (8000)...
:: STRESS TEST: Releasing the primary gateway port
for /f "tokens=5" %%i in ('netstat -ano ^| findstr :8000 ^| findstr LISTENING') do (
    if not "!SEEN_%%i!"=="1" (
        set "SEEN_%%i=1"
        echo [KILL] Releasing PID %%i on Port 8000...
        taskkill /F /PID %%i /T >nul 2>&1
    )
)

echo [3/7] Terminating Nexus Brain (Python/Uvicorn)...
taskkill /F /IM uvicorn.exe /T >nul 2>&1
taskkill /F /IM python.exe /T >nul 2>&1

echo [4/7] Terminating Nexus Body (Flutter/Dart Artifacts)...
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1

echo [5/7] Releasing UI Surface (Chrome)...
:: Logic: Narrowly targets only Chrome instances labeled "Nexus"
taskkill /F /IM chrome.exe /FI "WINDOWTITLE eq Nexus*" /T >nul 2>&1

echo [6/7] Closing Master Launcher & Orphaned Shells...
taskkill /F /FI "WINDOWTITLE eq NEXUS PROTOCOL - Master Launcher*" /T >nul 2>&1
taskkill /F /IM cmd.exe /FI "WINDOWTITLE eq NEXUS_*" /T >nul 2>&1

echo [7/7] Terminating External Bridge (Ngrok)...
taskkill /F /IM ngrok.exe /T >nul 2>&1

:: Delay for OS file handle release
timeout /t 1 /nobreak > nul

echo.
echo [CLEANUP] Purging Python Cache...
for /d /r "%~dp0" %%d in (__pycache__) do (
    if exist "%%d" rd /s /q "%%d" >nul 2>&1
)

echo.
echo [VERIFY] Process Audit:
echo ----------------------------------------------------
netstat -ano | findstr :8000 >nul && echo [!] ALERT: Port 8000 Stuck || echo [OK] Brain Offline
tasklist | findstr ngrok >nul && echo [!] ALERT: Bridge Stuck || echo [OK] Bridge Offline
echo ----------------------------------------------------

echo.
echo [OK] SYSTEM SHUTDOWN COMPLETE
echo ====================================================
timeout /t 2
exit