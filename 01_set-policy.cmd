@ECHO OFF
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList 'Set-ExecutionPolicy Bypass -Force' -Verb RunAs}"
Sleep 4
shutdown -r -t 0