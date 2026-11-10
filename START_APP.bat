@echo off
title JobLens - Data Job Analytics
cd /d "%~dp0"
set "LOG=%~dp0setup_log.txt"
echo ============================================================
echo   JobLens - Job Offers Analysis (NLP + ML + Flask)
echo ============================================================
echo Setup started %date% %time% > "%LOG%"

rem --- 1. Find a supported Python (3.13 / 3.12 / 3.11). Python 3.14+ has no wheels yet
rem        for scikit-learn 1.9.1 / NumPy / SciPy, so it is not used.
set "PY="
py -3.13 --version >nul 2>nul && set "PY=py -3.13"
if not defined PY (py -3.12 --version >nul 2>nul && set "PY=py -3.12")
if not defined PY (py -3.11 --version >nul 2>nul && set "PY=py -3.11")
if not defined PY (
  echo [0/3] Python 3.13 not found - installing it with the Python Install Manager ...
  py install 3.13 >> "%LOG%" 2>&1
  py -3.13 --version >nul 2>nul && set "PY=py -3.13"
)
if not defined PY goto :nopython
echo Using:
%PY% --version
%PY% --version >> "%LOG%" 2>&1

rem --- 2. Virtual environment (rebuilt if a previous install did not finish)
if exist ".venv" if not exist ".venv\installed.ok" (
  echo Removing an incomplete .venv from a previous attempt ...
  rmdir /s /q ".venv"
)
if not exist ".venv\Scripts\python.exe" (
  echo [1/3] Creating the virtual environment .venv ...
  %PY% -m venv .venv >> "%LOG%" 2>&1 || goto :err
)
call ".venv\Scripts\activate.bat"

if not exist ".venv\installed.ok" (
  echo [2/3] Installing the libraries - first run only, 3-5 minutes. Details: setup_log.txt
  python -m pip install --upgrade pip >> "%LOG%" 2>&1
  python -m pip install -r requirements.txt >> "%LOG%" 2>&1 || goto :err
  echo ok> ".venv\installed.ok"
  echo       Libraries installed.
) else (
  echo [2/3] Libraries already installed.
)

echo [3/3] Starting the web app on http://127.0.0.1:5000  (keep this window open; close it to stop)
set PYTHONUNBUFFERED=1
rem open the browser only once the server answers
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "for($i=0;$i -lt 900;$i++){try{(New-Object Net.WebClient).DownloadString('http://127.0.0.1:5000/api/health')|Out-Null; Start-Process 'http://127.0.0.1:5000'; break}catch{Start-Sleep 2}}"
python run.py 2>&1
echo.
echo The app stopped. If this was not intended, read the messages above.
pause
exit /b 0

:nopython
echo.
echo Could not find or install Python 3.13.
echo Install it from https://www.python.org/downloads/release/python-3139/
echo (Windows installer 64-bit, tick "Add python.exe to PATH"), then double-click this file again.
pause
exit /b 1

:err
echo.
echo Installation failed. The last lines of setup_log.txt:
powershell -NoProfile -Command "Get-Content -Tail 25 '%LOG%'"
pause
exit /b 1
