@echo off
rem Install secret-leak shield: pre-commit + Gitleaks (Windows).
setlocal
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo Run this script inside a Git repository.
  exit /b 1
)
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do set "ROOT=%%i"
set "SRC=%~dp0"

where pre-commit >nul 2>&1
if errorlevel 1 (
  where python >nul 2>&1
  if errorlevel 1 (
    echo Python 3 is required: https://www.python.org/downloads/
    exit /b 1
  )
  python -m pip install --user pre-commit
  if errorlevel 1 exit /b 1
)

for %%f in (.pre-commit-config.yaml .gitleaksignore .gitleaks.toml) do (
  if exist "%ROOT%\%%f" (
    echo %%f already exists, not overwriting.
  ) else (
    copy "%SRC%%%f" "%ROOT%\%%f" >nul
    echo Copied %%f
  )
)

cd /d "%ROOT%"
where pre-commit >nul 2>&1
if errorlevel 1 (
  python -m pre_commit install
) else (
  pre-commit install
)
echo Done. Hook installed. First run downloads Gitleaks, internet needed.
echo Check: pre-commit run --all-files
endlocal
