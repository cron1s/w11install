@ECHO OFF
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList 'Set-ExecutionPolicy Bypass -Force' -Verb RunAs}"
PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0\installation.ps1""' -Verb RunAs}"