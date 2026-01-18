@echo off
title NEXUS PROTOCOL - Emergency Shutdown
color 0c

echo ====================================================
echo         NEXUS PROTOCOL: PURGING SYSTEM (v1.3.1)
echo ====================================================
echo.

:: 1. Kill the Brain (Python/Uvicorn)
echo [1/4] 🧠 Terminating Nexus Brain & Uvicorn Workers...
:: We kill by Window Title first, then by image name to ensure all workers die
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRAIN*" /T > nul 2>&1
taskkill /F /IM uvicorn.exe /T > nul 2>&1
taskkill /F /IM python.exe /FI "MODULES eq _sqlite3.pyd" > nul 2>&1

:: 2. Kill the Body (Flutter/Dart)
echo [2/4] 👕 Terminating Nexus Body (Dart SDK)...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BODY*" /T > nul 2>&1
taskkill /F /IM dart.exe /T > nul 2>&1

:: 3. Kill the Bridge (ngrok)
echo [3/4] 📡 Terminating Nexus Bridge...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRIDGE*" /T > nul 2>&1
taskkill /F /IM ngrok.exe /T > nul 2>&1

:: 4. Final Cleanup (Release all NEXUS shells)
echo [4/4] 🧹 Releasing socket locks...
taskkill /F /IM cmd.exe /FI "WINDOWTITLE eq NEXUS_*" > nul 2>&1

echo.
echo ----------------------------------------------------
echo ✅ SYSTEM PURGED: PORTS 8000 & 8080 RELEASED
echo ----------------------------------------------------
echo.
timeout /t 2 > nul
exit