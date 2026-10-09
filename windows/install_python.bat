@echo off
setlocal EnableExtensions

rem ============================================================
rem  Step 1 - install Python 3.10.11 (offline)
rem  Keep this .bat in the same folder as python310\ and
rem  packages_win\. Double-click to run. Administrator rights
rem  are required.
rem  After this finishes, run install_libs.bat
rem ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~s0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

rem ---- skip if Python 3.10 is already installed ----
py -3.10 -c "import sys; sys.exit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
if not errorlevel 1 (
    echo Python 3.10 is already installed on this machine:
    py -3.10 --version
    echo.
    echo Skipping installation.
    echo Next: run install_libs.bat to install the libraries.
    pause
    exit /b 0
)

if not exist "%~dp0python310\python-3.10.11-amd64.exe" (
    echo [ERROR] python310\python-3.10.11-amd64.exe not found.
    echo         Keep this .bat next to the python310 folder.
    pause
    exit /b 1
)

set "PYSETUP_LOG=%TEMP%\python310_install.log"

echo ==============================================
echo  [1/2] Installing Python 3.10.11 ...
echo ==============================================
start /wait "" "%~dp0python310\python-3.10.11-amd64.exe" /quiet InstallAllUsers=1 PrependPath=0 Include_pip=1 Include_test=0 Include_launcher=1 /log "%PYSETUP_LOG%"
set "RC=%errorlevel%"
echo Installer exit code: %RC%

if "%RC%"=="3010" (
    echo [OK] Installed. A reboot is required before first use.
    pause
    exit /b 0
)
if not "%RC%"=="0" (
    echo [ERROR] Python installation failed. Exit code: %RC%
    echo Setup log: %PYSETUP_LOG%
    pause
    exit /b 1
)

echo.
echo ==============================================
echo  [2/2] Verifying ...
echo ==============================================
py -3.10 -c "import sys; sys.exit(0 if sys.version_info[:2]==(3,10) else 1)"
if errorlevel 1 (
    echo [ERROR] py -3.10 not available after installation.
    pause
    exit /b 1
)

py -3.10 --version
py -3.10 -m pip --version

echo.
echo ==============================================
echo  Python is ready.
echo  Next: run install_libs.bat
echo ==============================================
pause
endlocal
