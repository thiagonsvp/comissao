@echo off
title Sistema de Comissoes - Servidor Local
echo.
echo  ======================================
echo   Sistema de Comissoes - Iniciando...
echo  ======================================
echo.
echo  Servidor: http://localhost:3030
echo  Pressione Ctrl+C para encerrar.
echo.
cd /d "%~dp0"
start "" "chrome.exe" "http://localhost:3030"
node server.js
pause
