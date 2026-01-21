@echo off
setlocal enabledelayedexpansion
title NEXUS PROTOCOL - Emergency Shutdown (Hardened v1.3.1)
color 0c

:: Ensure we are working from the project root
cd /d "%~dp0"

echo ====================================================
echo             NEXUS PROTOCOL: EMERGENCY SHUTDOWN
echo             PHASE 1.3.1 - DETERMINISTIC CLEANUP
echo ====================================================
echo.

echo [1/6] Authoritative Port Release (8000, 8080)...
:: STRESS TEST: Kill by port is the most reliable way to free the node
for %%P in (8000 8080) do (
    for /f "tokens=5" %%i in ('netstat -ano ^| findstr :%%P ^| findstr LISTENING') do (
        if not "!SEEN_%%i!"=="1" (
            set "SEEN_%%i=1"
            echo [KILL] Releasing PID %%i on Port %%P...
            taskkill /F /PID %%i /T >nul 2>&1
        )
    )
)

echo [2/6] Terminating Nexus Brain (Python/Uvicorn)...
taskkill /F /IM uvicorn.exe /T >nul 2>&1
taskkill /F /IM python.exe /T >nul 2>&1

echo [3/6] Terminating Nexus Body (Flutter/Dart)...
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM dart.exe /T >nul 2>&1

echo [4/6] Releasing UI Surface (Chrome)...
:: Logic: Specifically targets Chrome windows opened for Nexus
taskkill /F /IM chrome.exe /FI "WINDOWTITLE eq Nexus*" /T >nul 2>&1

echo [5/6] Closing Master Launcher & Orphaned Shells...
taskkill /F /FI "WINDOWTITLE eq NEXUS PROTOCOL - Master Launcher*" /T >nul 2>&1
taskkill /F /IM cmd.exe /FI "WINDOWTITLE eq NEXUS_*" /T >nul 2>&1

echo [6/6] Terminating External Bridge (Ngrok)...
taskkill /F /IM ngrok.exe /T >nul 2>&1

:: STRESS TEST: Delay for file handle release
timeout /t 1 /nobreak > nul

echo.
echo [CLEANUP] Purging Python Cache...
for /d /r "%~dp0" %%d in (__pycache__) do (
    if exist "%%d" rd /s /q "%%d" >nul 2>&1
)

echo.
echo [VERIFY] Process Audit:
echo ----------------------------------------------------
netstat -ano | findstr :8000 >nul && echo [!] ALERT: Brain Port 8000 Stuck || echo [OK] Brain Offline
netstat -ano | findstr :8080 >nul && echo [!] ALERT: Body Port 8080 Stuck || echo [OK] Body Offline
tasklist | findstr ngrok >nul && echo [!] ALERT: Bridge Stuck || echo [OK] Bridge Offline
echo ----------------------------------------------------

echo.
echo [OK] SYSTEM SHUTDOWN COMPLETE (All Shells Released)
echo ====================================================
timeout /t 2
exit