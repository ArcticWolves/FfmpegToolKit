@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\jxl.bat
rem
rem Извлечение кадра из видео или конвертация изображения в
rem JPEG XL (.jxl).
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Distance (0 = lossless)
rem   - Effort (1-9)
rem
rem Используемый кодек:
rem   libjxl
rem
rem Особенности JPEG XL:
rem   - Современный формат изображений.
rem   - Поддерживает lossless и lossy.
rem   - Поддерживает HDR и alpha channel.
rem
rem Требование:
rem   FFmpeg должен быть собран с поддержкой libjxl.
rem
rem Проверить:
rem   ffmpeg -encoders | findstr jxl
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html
rem ============================================================

rem ------------------------------------------------------------
rem Проверка конфигурации
rem ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

rem ------------------------------------------------------------
rem Проверка входного файла
rem ------------------------------------------------------------
if not defined INPUT_FILE (
    echo.
    echo [ERROR] INPUT_FILE не задан.
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

rem ------------------------------------------------------------
rem Получение имени входного файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Параметры по умолчанию
rem ------------------------------------------------------------
set "TIMECODE=00:00:00"
set "DISTANCE=1.0"
set "EFFORT=7"

:MAIN_MENU
cls

echo ============================================================
echo                        JPEG XL
echo ============================================================
echo.
echo Входной файл:
echo   %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Distance:
echo   %DISTANCE%
echo.
echo Effort:
echo   %EFFORT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Указать Distance
echo  3. Указать Effort
echo  4. Создать JXL
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_DISTANCE
if "%CHOICE%"=="3" goto SET_EFFORT
if "%CHOICE%"=="4" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:SET_TIMECODE
cls
echo.
echo Примеры:
echo   00:00:00
echo   00:01:23
echo   00:01:23.500
echo.
set "NEW_TIMECODE="
set /p "NEW_TIMECODE=Введите таймкод [%TIMECODE%]: "

if defined NEW_TIMECODE (
    set "TIMECODE=%NEW_TIMECODE%"
)

goto MAIN_MENU


:SET_DISTANCE
cls
echo.
echo Distance:
echo   0.0 = lossless
echo   0.5 = очень высокое качество
echo   1.0 = рекомендуемое значение
echo   3.0 = меньший размер файла
echo.
set "NEW_DISTANCE="
set /p "NEW_DISTANCE=Введите значение [%DISTANCE%]: "

if defined NEW_DISTANCE (
    set "DISTANCE=%NEW_DISTANCE%"
)

goto MAIN_MENU


:SET_EFFORT
cls
echo.
echo Effort:
echo   1 = быстро
echo   7 = рекомендуемое значение
echo   9 = максимальное сжатие
echo.
set "NEW_EFFORT="
set /p "NEW_EFFORT=Введите значение [%EFFORT%]: "

if defined NEW_EFFORT (
    set "EFFORT=%NEW_EFFORT%"
)

goto MAIN_MENU


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=jxl"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание JPEG XL
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Distance:
echo   %DISTANCE%
echo.
echo Effort:
echo   %EFFORT%
echo.
echo Выходной файл:
echo   %OUTPUT_FILE%
echo.
echo ============================================================
echo.
echo Нажмите любую клавишу для запуска...
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-ss %TIMECODE% ^
-i "%INPUT_FILE%" ^
-frames:v 1 ^
-c:v libjxl ^
-distance %DISTANCE% ^
-effort %EFFORT% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать JPEG XL.
    echo [ERROR] Возможно, текущая сборка FFmpeg не содержит libjxl.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo JPEG XL файл:
echo   %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "OPEN_RESULT="
    set /p "OPEN_RESULT=Открыть изображение в FFplay? (Y/N): "

    if /i "%OPEN_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
