@echo off
chcp 65001 > nul
title Sarashina Proxy Server
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_proxy.ps1"

if %ERRORLEVEL% neq 0 (
    echo.
    echo 異常終了したため、画面を保持しています。
    pause
)
