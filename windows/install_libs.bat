@echo off
setlocal EnableExtensions

rem ============================================================
rem  Step 2 - install all libraries (offline)
rem  Keep this .bat in the same folder as packages_win\ and
rem  requirements.txt. Double-click to run.
rem  Run install_python.bat first if Python is not installed yet.
rem ============================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~s0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

rem ---- never use bare "python": it may point to another version ----
py -3.10 -c "import sys; sys.exit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python 3.10 not found. Run install_python.bat first.
    pause
    exit /b 1
)

if not exist "%~dp0requirements.txt" (
    echo [ERROR] requirements.txt not found.
    pause
    exit /b 1
)

echo ==============================================
echo  [1/2] Installing 138 packages (offline) ...
echo  This takes about 3 minutes.
echo ==============================================
py -3.10 -m pip install --no-index --find-links=packages_win -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Installation failed.
    pause
    exit /b 1
)
echo [OK] Packages installed.

echo.
echo ==============================================
echo  [2/2] Verifying ...
echo ==============================================
py -3.10 -c "import numpy,pandas,sklearn,xgboost,lightgbm,shap,matplotlib,seaborn,openpyxl,jupyterlab; print('OK - all packages importable')"
if errorlevel 1 (
    echo [ERROR] Import verification failed.
    pause
    exit /b 1
)

echo.
echo ==============================================
echo  All done.
echo  Start Jupyter:  py -3.10 -m jupyter lab
echo ==============================================
pause
endlocal
