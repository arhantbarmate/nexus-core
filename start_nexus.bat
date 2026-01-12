@echo off
:: Windows-only orchestration script for Phase 1.1 feasibility
TITLE Nexus Protocol - Infrastructure Node
COLOR 0B

echo ==========================================
echo    NEXUS PROTOCOL: PHASE 1.1 BOOT
echo ==========================================
echo.

:: Sanity check: Python availability
echo [CHECK] Verifying Python installation...
python --version
echo.

:: 1. Launch the Brain (Backend) - Green Terminal
echo [1/2] Initializing Brain (FastAPI Execution Engine)...
start "NEXUS BRAIN" cmd /k "color 0A && cd backend && venv\Scripts\activate && python -m uvicorn main:app --reload"

:: Wait briefly to avoid race conditions
timeout /t 3 /nobreak >nul

:: 2. Launch the Body (Frontend) - Blue Terminal
echo [2/2] Initializing Body (Flutter Dashboard)...
start "NEXUS BODY" cmd /k "color 0B && cd client && flutter run -d windows"

echo.
echo ------------------------------------------
echo Status: Systems Online
echo Backend API: http://127.0.0.1:8000
echo ------------------------------------------
echo.
echo Press any key to exit this launcher.
pause >nul
