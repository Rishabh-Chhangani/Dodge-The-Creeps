@echo off
setlocal
cd /d "%~dp0\.."
echo Launching Dodge the Creeps Automated Release Pipeline...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0release.ps1" %*
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Release automation encountered an error.
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] Release completed successfully.
endlocal
