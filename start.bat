@echo off
REM  Launch the Bantu web app on http://localhost:8080
cd /d "%~dp0"

if "%PORT%"=="" set PORT=8080

REM  Prefer bantu.exe in this folder (e.g. from the chatbantu-windows-x64 zip),
REM  else fall back to bantu.exe on PATH.
if exist "bantu.exe" (
    set BANTU=bantu.exe
) else (
    where bantu.exe >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] bantu.exe not found.
        echo          Place bantu.exe + its DLLs in this folder, or install bantu system-wide.
        pause
        exit /b 1
    )
    set BANTU=bantu.exe
)

echo Starting on http://localhost:%PORT% ...
"%BANTU%" run main.b
pause
