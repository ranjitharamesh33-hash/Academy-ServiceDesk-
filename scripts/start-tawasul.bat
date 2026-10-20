@echo off
cd /d "%~dp0\.."
echo Building and starting the Tawasul portal...
docker compose up -d --build
if errorlevel 1 (
  echo.
  echo Docker could not start the portal. Make sure Docker Desktop is open and running, then try again.
  pause
  exit /b 1
)
echo.
echo Tawasul is running at http://localhost:8080
start "" http://localhost:8080
timeout /t 15
