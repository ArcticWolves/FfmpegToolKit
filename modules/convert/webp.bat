@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\webp.bat
rem
rem Извлечение кадра из видео или конвертация изображения в WebP.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Quality (0-100)
rem   - Lossless (Y/N)
rem
rem Используемый кодек:
rem   libwebp
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-codecs.html#libwebp
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
set "TIMECODE=00:00:00"
set "QUALITY=90"
set "LOSSLESS=0"

:MAIN_MENU
cls

echo ============================================================
echo                         WebP
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Quality:
echo   %QUALITY%
echo.
echo Lossless:
if "%LOSSLESS%"=="1" (
    echo   Yes
) else (
    echo   No
)
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Указать качество (0-100)
echo  3. Toggle Lossless
echo  4. Извлечь изображение
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_QUALITY
if "%CHOICE%"=="3" goto TOGGLE_LOSSLESS
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


:SET_QUALITY
cls
echo.
echo Quality:
echo   100 = максимальное качество
echo   90  = рекомендуемое значение
echo   75  = хороший баланс
echo.
set "NEW_QUALITY="
set /p "NEW_QUALITY=Введите качество [%QUALITY%]: "

if defined NEW_QUALITY (
    set "QUALITY=%NEW_QUALITY%"
)

goto MAIN_MENU


:TOGGLE_LOSSLESS
if "%LOSSLESS%"=="1" (
    set "LOSSLESS=0"
) else (
    set "LOSSLESS=1"
)
goto MAIN_MENU


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%SAFE_TIMECODE%.webp"

if "%LOSSLESS%"=="1" (
    set "WEBP_OPTIONS=-lossless 1 -compression_level 6"
) else (
    set "WEBP_OPTIONS=-quality %QUALITY% -compression_level 6"
)

cls
echo ============================================================
echo                 Конвертация в WebP
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Quality:
echo   %QUALITY%
echo.
echo Lossless:
echo   %LOSSLESS%
echo.
echo Параметры:
echo   %WEBP_OPTIONS%
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
-c:v libwebp ^
%WEBP_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать WebP.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo WebP файл:
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