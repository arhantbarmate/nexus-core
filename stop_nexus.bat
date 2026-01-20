@echo off
title NEXUS PROTOCOL - Emergency Shutdown
color 0c

:: Ensure we are working from the project root
cd /d "%~dp0"

echo ====================================================
echo          NEXUS PROTOCOL: EMERGENCY SHUTDOWN
echo ====================================================
echo.

echo [1/4] 🧠 Terminating Nexus Brain...
:: Targets specific Nexus window to avoid collateral damage
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRAIN*" /T >nul 2>&1

echo [2/4] 👕 Terminating Nexus Body...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BODY*" /T >nul 2>&1

echo [3/4] 🔗 Terminating External Bridge...
taskkill /F /FI "WINDOWTITLE eq NEXUS_BRIDGE*" /T >nul 2>&1

echo [4/4] 🧹 Cleaning Python Cache...
:: NOTE: nexus_vault.db is NOT touched. State remains sovereign and intact.
for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d" >nul 2>&1

echo.
echo ℹ️ If no processes were found, the system was already offline.
echo ====================================================
echo ✅ SYSTEM SHUTDOWN COMPLETE (Sovereign State Saved)
echo ====================================================
timeout /t 2
exit