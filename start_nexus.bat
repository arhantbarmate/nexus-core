@echo off

:: 1. Launch the Brain (Backend) - Green
start cmd /k "title NEXUS BRAIN && color 0A && cd backend && venv\Scripts\activate && python -m uvicorn main:app --reload"

:: Wait 3 seconds for the server to wake up
timeout /t 3 /nobreak

:: 2. Launch the Body (Frontend) - Blue
start cmd /k "title NEXUS BODY && color 0B && cd client && flutter run -d windows"

:: 3. Launch the Git Control (Version History) - Yellow/Gold
start cmd /k "title NEXUS GIT && color 06 && cd . && echo --- NEXUS GIT CONTROL ACTIVE --- && git status"