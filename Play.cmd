@echo off
setlocal
set "GODOT=C:\Program Files (x86)\Godot\Godot.exe"
if not exist "%GODOT%" (
  echo Godot was not found at "%GODOT%".
  echo Import project.godot with a Godot 4.x editor instead.
  pause
  exit /b 1
)
start "" /D "%~dp0." "%GODOT%" --path "%~dp0."
