@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\filters\color_hue.bat
::
:: FFmpeg hue filter: hue angle and saturation.
:: ============================================================

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
    echo [ERROR] Входной файл не выбран.
    echo.
    pause
    exit /b 1
)

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

:MAIN_MENU
cls
echo ============================================================
echo                         Hue
echo ============================================================
echo.
echo Оттенок задается в градусах.
echo Насыщенность: 1.0 = без изменений.
echo.

set "HUE_DEGREES="
set /p "HUE_DEGREES=Оттенок, градусы [0]: "
if not defined HUE_DEGREES set "HUE_DEGREES=0"

set "SATURATION="
set /p "SATURATION=Насыщенность [1.0]: "
if not defined SATURATION set "SATURATION=1.0"

set "VIDEO_FILTER=hue=h=%HUE_DEGREES%*PI/180:s=%SATURATION%"

set "OUTPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_SUFFIX=hue"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto EXIT_MODULE

set "EDIT_ALLOW_AUDIO_COPY=1"
call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
if errorlevel 1 goto EXIT_MODULE

cls
echo ============================================================
echo                         Hue
echo ============================================================
echo.
echo Фильтр:
echo %VIDEO_FILTER%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%VIDEO_FILTER%" ^
-c:v %EDIT_VIDEO_CODEC% %EDIT_VIDEO_OPTIONS% ^
-c:a %EDIT_AUDIO_CODEC% %EDIT_AUDIO_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Цветокоррекция завершилась с ошибкой.
    echo.
    pause
    goto EXIT_MODULE
)

echo.
echo ============================================================
echo                         Готово
echo ============================================================
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть результат в FFplay? (Y/N): "
    if /i "!PLAY_RESULT!"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause

:EXIT_MODULE
endlocal
exit /b 0
