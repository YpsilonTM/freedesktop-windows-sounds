@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-FreedesktopSounds.ps1" %*
pause
