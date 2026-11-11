@echo off
chcp 65001 > nul
title Sarashina Proxy Server
cd /d "%~dp0"

rem Set launch flag from batch file
set LAUNCHED_BY_BAT=1

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_proxy.ps1"
set PS_EXIT_CODE=%ERRORLEVEL%

if %PS_EXIT_CODE% neq 0 (
    echo.
    echo 異常終了したため、画面を保持しています。 [終了コード: %PS_EXIT_CODE%]
    echo.
    pause
    exit /b %PS_EXIT_CODE%
)

echo.
pause
