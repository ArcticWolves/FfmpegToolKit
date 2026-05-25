@echo off
setlocal EnableExtensions EnableDelayedExpansion

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

if not defined INPUT_FILE (
    echo.
    echo [ERROR] INPUT_FILE не задан.
    echo [ERROR] Сначала выберите входной файл.
    echo.
    pause
    exit /b 1
)

if not exist "%INPUT_FILE%" (
    echo.
    echo [ERROR] Входной файл не найден:
    echo         %INPUT_FILE%
    echo.
    pause
    exit /b 1
)

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

set /p "HUE=Hue shift (degrees, default 0): "
set /p "SAT=Saturation (default 1.0): "

if not defined HUE set "HUE=0"
if not defined SAT set "SAT=1.0"

set "VF=hue=h=%HUE%:s=%SAT%"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_hue%INPUT_EXT%"

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
    -i "%INPUT_FILE%" ^
    -vf "%VF%" ^
    -c:v libopenh264 ^
    -b:v 5M ^
    -c:a copy ^
    "%OUTPUT_FILE%"

endlocal
exit /b 0
