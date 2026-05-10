@echo off

set "FFMPEG=ffmpeg.exe"
set "FFPROBE=ffprobe.exe"
set "FFPLAY=ffplay.exe"


set "INPUT_DIR=input"
set "OUTPUT_DIR=output"
set "TEMP_DIR=temp"
set "LOG_DIR=logs"

if not exist "%INPUT_DIR%" mkdir "%INPUT_DIR%"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

where "%FFMPEG%" >nul
if errorlevel 1 (
    echo FFmpeg не найден в PATH.
    pause
    exit /b 1
)