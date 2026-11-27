@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo.
echo ============================================================
echo     Velotoma Media Engine - Automated Windows Installer
echo ============================================================
echo.

set "DEV_MODE=0"
if /I "%~1"=="--dev" set "DEV_MODE=1"
if /I "%~1"=="-d" set "DEV_MODE=1"

if "%DEV_MODE%"=="1" (
    set "PREFIX=Velotoma-Media-Engine-Dev-Setup-v"
) else (
    set "PREFIX=Velotoma-Media-Engine-Setup-v"
)

set "SCRIPT_DIR=%~dp0"
set "INSTALLER="

for %%D in ("%SCRIPT_DIR%." "%SCRIPT_DIR%..\release" "%SCRIPT_DIR%..\..\release") do (
    if not defined INSTALLER (
        for /f "delims=" %%F in ('dir /b /a-d /o-d "%%~fD\%PREFIX%*.exe" 2^>nul') do (
            if not defined INSTALLER set "INSTALLER=%%~fD\%%F"
        )
    )
)

if defined INSTALLER if exist "%INSTALLER%" (
    echo [FOUND] Local installer package: %INSTALLER%
    echo [INFO]  Launching silent installation...
    "%INSTALLER%" /SILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS
    set "EXIT_CODE=%ERRORLEVEL%"
    echo.
    if "!EXIT_CODE!"=="0" (
        echo ============================================================
        echo   Velotoma Media Engine installed successfully!
        echo ============================================================
    ) else (
        echo [WARN] Installer exited with code !EXIT_CODE!.
    )
    if /I not "%~2"=="--no-pause" pause
    exit /b !EXIT_CODE!
)

echo [INFO] No local installer .exe found alongside script.
echo [INFO] Fetching latest verified release via PowerShell installer...
if "%DEV_MODE%"=="1" set "VELOTOMA_DEV=1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u1='https://raw.githubusercontent.com/KrSnaGit112/OCU/main/install.ps1'; $u2='https://github.com/KrSnaGit112/OCU/releases/latest/download/install.ps1'; try { irm $u1 -TimeoutSec 15 | iex } catch { irm $u2 -TimeoutSec 20 | iex }"
set "PS_CODE=%ERRORLEVEL%"
if /I not "%~2"=="--no-pause" pause
exit /b %PS_CODE%
