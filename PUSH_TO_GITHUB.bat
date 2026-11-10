@echo off
title Push JobLens project to GitHub
cd /d "%~dp0"
set "REPO=https://github.com/abiiiiir123/AdvancedLearningGraph-Project.git"

rem ---- 1. find or install Git ------------------------------------------------
set "GIT="
where git >nul 2>nul && set "GIT=git"
if not defined GIT if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
if not defined GIT if exist "%LOCALAPPDATA%\Programs\Git\cmd\git.exe" set "GIT=%LOCALAPPDATA%\Programs\Git\cmd\git.exe"
if not defined GIT (
  if not exist "%USERPROFILE%\Downloads\Git-2.56.0.4-64-bit.exe" (
    echo Git installer not found in Downloads. Install Git from https://git-scm.com/download/win
    pause & exit /b 1
  )
  echo [1/4] Installing Git silently - click YES if Windows asks for permission ...
  "%USERPROFILE%\Downloads\Git-2.56.0.4-64-bit.exe" /VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES
  if exist "%ProgramFiles%\Git\cmd\git.exe" set "GIT=%ProgramFiles%\Git\cmd\git.exe"
  if exist "%LOCALAPPDATA%\Programs\Git\cmd\git.exe" set "GIT=%LOCALAPPDATA%\Programs\Git\cmd\git.exe"
)
if not defined GIT (echo Git installation failed. & pause & exit /b 1)
echo Using Git: "%GIT%"

rem ---- 2. commit ---------------------------------------------------------------
echo [2/4] Preparing the commit ...
if not exist ".git" "%GIT%" init
"%GIT%" config user.name "Aziz Znaidi"
"%GIT%" config user.email "aziz.znaidi@esprit.tn"
"%GIT%" add .
"%GIT%" commit -m "Job offers NLP analysis: TF-IDF+LogReg, DistilBERT, K-Means, knowledge graph, Flask app"
"%GIT%" branch -M main
"%GIT%" remote remove origin >nul 2>nul
"%GIT%" remote add origin %REPO%

rem ---- 3. push (a GitHub sign-in window opens the first time) -------------------
echo [3/4] Pushing to %REPO%
echo       A GitHub sign-in window will open: sign in with an account that can write to this repo.
"%GIT%" push -u origin main
if errorlevel 1 (
  echo Push refused - merging the files already on GitHub, then pushing again ...
  "%GIT%" pull origin main --allow-unrelated-histories --no-edit
  "%GIT%" push -u origin main
)
echo [4/4] Done. Check https://github.com/abiiiiir123/AdvancedLearningGraph-Project
pause
