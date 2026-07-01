@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\filters\color_equalizer.bat
::
:: FFmpeg huesaturation filter: intensity and saturation.
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
echo                   Color Adjust
echo ============================================================
echo.
echo Используется фильтр huesaturation, доступный в текущей сборке FFmpeg.
echo.

set "INTENSITY="
set /p "INTENSITY=Интенсивность/яркость [-1.0..1.0, 0.0]: "
if not defined INTENSITY set "INTENSITY=0.0"

set "SATURATION_SHIFT="
set /p "SATURATION_SHIFT=Сдвиг насыщенности [-1.0..1.0, 0.0]: "
if not defined SATURATION_SHIFT set "SATURATION_SHIFT=0.0"

set "STRENGTH="
set /p "STRENGTH=Сила фильтра [1.0]: "
if not defined STRENGTH set "STRENGTH=1.0"

set "VIDEO_FILTER=huesaturation=intensity=%INTENSITY%:saturation=%SATURATION_SHIFT%:strength=%STRENGTH%"

set "OUTPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_SUFFIX=eq"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto EXIT_MODULE

set "EDIT_ALLOW_AUDIO_COPY=1"
call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
if errorlevel 1 goto EXIT_MODULE

cls
echo ============================================================
echo                   Color Adjust
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
