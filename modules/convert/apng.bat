@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\apng.bat
rem
rem Создание APNG (Animated PNG).
rem
rem Использование:
rem   - Из видео создаётся анимированный PNG.
rem
rem Пользователь задаёт:
rem   - Начальный таймкод
rem   - Длительность
rem   - FPS
rem   - Ширину (опционально)
rem
rem Особенности:
rem   - APNG поддерживает альфа-канал.
rem   - Потерь качества нет.
rem   - Лучше GIF по качеству.
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-formats.html#apng
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
rem Получение имени файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "START_TIME=00:00:00"
set "DURATION=3"
set "FPS=15"
set "WIDTH=640"

:MAIN_MENU
cls

echo ============================================================
echo                          APNG
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Start Time:
echo   %START_TIME%
echo.
echo Duration:
echo   %DURATION% sec
echo.
echo FPS:
echo   %FPS%
echo.
echo Width:
echo   %WIDTH%
echo.
echo ============================================================
echo.
echo  1. Указать начальный таймкод
echo  2. Указать длительность
echo  3. Указать FPS
echo  4. Указать ширину
echo  5. Создать APNG
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_START_TIME
if "%CHOICE%"=="2" goto SET_DURATION
if "%CHOICE%"=="3" goto SET_FPS
if "%CHOICE%"=="4" goto SET_WIDTH
if "%CHOICE%"=="5" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:SET_START_TIME
cls
echo.
echo Примеры:
echo   00:00:00
echo   00:01:23.500
echo.
set "NEW_START_TIME="
set /p "NEW_START_TIME=Введите таймкод [%START_TIME%]: "

if defined NEW_START_TIME (
    set "START_TIME=%NEW_START_TIME%"
)

goto MAIN_MENU


:SET_DURATION
cls
echo.
set "NEW_DURATION="
set /p "NEW_DURATION=Введите длительность в секундах [%DURATION%]: "

if defined NEW_DURATION (
    set "DURATION=%NEW_DURATION%"
)

goto MAIN_MENU


:SET_FPS
cls
echo.
set "NEW_FPS="
set /p "NEW_FPS=Введите FPS [%FPS%]: "

if defined NEW_FPS (
    set "FPS=%NEW_FPS%"
)

goto MAIN_MENU


:SET_WIDTH
cls
echo.
echo Используйте -1 для оригинального размера.
echo.
set "NEW_WIDTH="
set /p "NEW_WIDTH=Введите ширину [%WIDTH%]: "

if defined NEW_WIDTH (
    set "WIDTH=%NEW_WIDTH%"
)

goto MAIN_MENU


:RUN
set "SAFE_TIME=%START_TIME::=-%"
set "SAFE_TIME=%SAFE_TIME:.=-%"
set "OUTPUT_EXT=apng"
set "OUTPUT_SUFFIX=%SAFE_TIME%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

if "%WIDTH%"=="-1" (
    set "VIDEO_FILTER=fps=%FPS%"
) else (
    set "VIDEO_FILTER=fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos"
)

cls
echo ============================================================
echo                    Создание APNG
echo ============================================================
echo.
echo Start Time:
echo   %START_TIME%
echo.
echo Duration:
echo   %DURATION%
echo.
echo FPS:
echo   %FPS%
echo.
echo Filter:
echo   %VIDEO_FILTER%
echo.
echo Выходной файл:
echo   %OUTPUT_FILE%
echo.
echo ============================================================
echo.
echo Нажмите любую клавишу для запуска...
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-ss %START_TIME% ^
-t %DURATION% ^
-i "%INPUT_FILE%" ^
-vf "%VIDEO_FILTER%" ^
-plays 0 ^
-f apng ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать APNG.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo APNG файл:
echo   %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%PLAY_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
