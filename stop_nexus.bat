@echo off
title NEXUS PROTOCOL - Emergency Shutdown
color 0c

echo ====================================================
echo        NEXUS PROTOCOL: PURGING SYSTEM...
echo ====================================================
echo.

:: 1. Kill the Brain
echo [1/4] 🧠 Terminating Nexus Brain...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRAIN*" /T > nul 2>&1
taskkill /F /IM uvicorn.exe > nul 2>&1

:: 2. Kill the Body
echo [2/4] 👕 Terminating Nexus Body...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BODY*" /T > nul 2>&1
taskkill /F /IM dart.exe > nul 2>&1

:: 3. Kill the Bridge (DETERMINISTIC ORDER: Window first, then Image)
echo [3/4] 📡 Terminating Nexus Bridge...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRIDGE*" /T > nul 2>&1
taskkill /F /IM ngrok.exe > nul 2>&1

:: 4. Final Cleanup (Global Nexus catch-all)
echo [4/4] 🧹 Cleaning Nexus command shells...
taskkill /F /IM cmd.exe /FI "WINDOWTITLE eq NEXUS_*" > nul 2>&1

echo.
echo ----------------------------------------------------
echo ✅ SYSTEM PURGED: ALL PORTS RELEASED
echo ----------------------------------------------------
echo.
timeout /t 3 > nul
exit