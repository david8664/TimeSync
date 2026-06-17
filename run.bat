@echo off
setlocal
cd /d "%~dp0"
title TimeSync Setup

echo.
echo ========================================
echo            TimeSync Setup
echo ========================================
echo.

REM ==========================================================
REM Check if .env exists
REM ==========================================================
if not exist ".env" goto CONFIGURE
goto CHECK_PYTHON

REM ==========================================================
REM Create configuration
REM ==========================================================
:CONFIGURE

echo Please enter your details:
echo ----------------------------------------

set /p INPUT_USER=Username: 
set /p INPUT_PASS=Password: 
set /p INPUT_URL=Site URL: 

(
    echo SYNERION_USERNAME=%INPUT_USER%
    echo SYNERION_PASSWORD=%INPUT_PASS%
    echo ATTENDANCE_URL=%INPUT_URL%
    echo HEADLESS=false
) > ".env"

echo.
echo Configuration saved to .env
echo.

REM ==========================================================
REM Check Python
REM ==========================================================
:CHECK_PYTHON

echo Checking for Python...
echo.

REM Portable Python
if exist "python\python.exe" (
    set "PYTHON=%~dp0python\python.exe"
    echo Using portable Python
    goto INSTALL_DEPS
)

REM System Python
python --version >nul 2>&1
if not errorlevel 1 (
    set "PYTHON=python"
    echo Using system Python
    goto INSTALL_DEPS
)

echo.
echo Python not found!
echo.
echo Download Python from:
echo https://www.python.org/downloads/
echo.
echo Make sure to enable:
echo Add Python to PATH
echo.
pause
exit /b 1

REM ==========================================================
REM Install dependencies
REM ==========================================================
:INSTALL_DEPS

if exist ".deps_installed" goto RUN_MAIN

echo.
echo Installing dependencies...
echo.

"%PYTHON%" -m pip install --upgrade pip
if errorlevel 1 goto INSTALL_FAILED

"%PYTHON%" -m pip install -r requirements.txt
if errorlevel 1 goto INSTALL_FAILED

echo.
echo Installing Chromium browser...
echo.

"%PYTHON%" -m playwright install chromium
if errorlevel 1 goto INSTALL_FAILED

type nul > ".deps_installed"

echo.
echo All dependencies installed.
echo.

goto RUN_MAIN

:INSTALL_FAILED
pause
exit /b 1

REM ==========================================================
REM Run application
REM ==========================================================
:RUN_MAIN

echo.
echo Starting TimeSync...
echo.

"%PYTHON%" "%~dp0main.py"

echo.
echo ----------------------------------------
echo TimeSync finished.
echo ----------------------------------------
pause