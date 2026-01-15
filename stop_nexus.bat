@echo off
TITLE Nexus Protocol - Sovereign Node Shutdown
COLOR 0C

echo ==================================================
echo   NEXUS PROTOCOL: SHUTTING DOWN NODE
echo ==================================================

echo [1/3] Terminating Chrome/Flutter sessions...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Nexus_Frontend*" /T >nul 2>&1

echo [2/3] Terminating FastAPI/Uvicorn sessions...
taskkill /F /IM uvicorn.exe /T >nul 2>&1
taskkill /F /FI "WINDOWTITLE eq Nexus_Backend*" /T >nul 2>&1

echo [3/3] Closing Launcher and Cleaning Up...
:: This line targets the "Start" terminal specifically
taskkill /F /FI "WINDOWTITLE eq Nexus Protocol - Sovereign Node Launcher*" /T >nul 2>&1
:: Final sweep for any remaining Nexus-titled windows
taskkill /F /IM conhost.exe /FI "WINDOWTITLE eq Nexus_*" /T >nul 2>&1

echo.
echo ==================================================
echo   SUCCESS: All Nexus windows and processes closed.
echo ==================================================
timeout /t 2
exit