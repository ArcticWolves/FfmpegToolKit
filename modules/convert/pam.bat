@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\pam.bat
rem
rem Извлечение кадра из видео или конвертация изображения в PAM.
rem
rem Формат:
rem   Portable Arbitrary Map (.pam)
rem
rem Особенности:
rem   - Поддерживает RGB, Grayscale и Alpha.
rem   - Часто используется в Netpbm.
rem   - Полностью lossless.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Тип tuple:
rem       RGB
rem       GRAYSCALE
rem       RGB_ALPHA
rem       GRAYSCALE_ALPHA
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#pam
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
rem Параметры по умолчанию
rem ------------------------------------------------------------
set "TIMECODE=00:00:00"
set "TUPLE_TYPE=RGB_ALPHA"
set "PIX_FMT=rgba"

:MAIN_MENU
cls

echo ============================================================
echo                          PAM
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Tuple Type:
echo   %TUPLE_TYPE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать Tuple Type
echo  3. Создать PAM
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_TUPLE_TYPE
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Ввод таймкода
rem ============================================================
:SET_TIMECODE
cls

echo ============================================================
echo                       Таймкод
echo ============================================================
echo.
echo Примеры:
echo   00:00:00
echo   00:01:23
echo   00:01:23.500
echo.
echo Текущее значение:
echo   %TIMECODE%
echo.

set "NEW_TIMECODE="
set /p "NEW_TIMECODE=Введите таймкод [%TIMECODE%]: "

if defined NEW_TIMECODE (
    set "TIMECODE=%NEW_TIMECODE%"
)

goto MAIN_MENU


rem ============================================================
rem Выбор Tuple Type
rem ============================================================
:SET_TUPLE_TYPE
cls

echo ============================================================
echo                     Tuple Type
echo ============================================================
echo.
echo  1. RGB
echo  2. GRAYSCALE
echo  3. RGB_ALPHA
echo  4. GRAYSCALE_ALPHA
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "TYPE_CHOICE="
set /p "TYPE_CHOICE=Выберите тип: "

if "%TYPE_CHOICE%"=="1" (
    set "TUPLE_TYPE=RGB"
    set "PIX_FMT=rgb24"
    goto MAIN_MENU
)

if "%TYPE_CHOICE%"=="2" (
    set "TUPLE_TYPE=GRAYSCALE"
    set "PIX_FMT=gray"
    goto MAIN_MENU
)

if "%TYPE_CHOICE%"=="3" (
    set "TUPLE_TYPE=RGB_ALPHA"
    set "PIX_FMT=rgba"
    goto MAIN_MENU
)

if "%TYPE_CHOICE%"=="4" (
    set "TUPLE_TYPE=GRAYSCALE_ALPHA"
    set "PIX_FMT=ya8"
    goto MAIN_MENU
)

if "%TYPE_CHOICE%"=="0" goto MAIN_MENU

goto SET_TUPLE_TYPE


rem ============================================================
rem Выполнение конвертации
rem ============================================================
:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%SAFE_TIMECODE%.pam"

cls
echo ============================================================
echo                    Создание PAM
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Tuple Type:
echo   %TUPLE_TYPE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
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
-pix_fmt %PIX_FMT% ^
-c:v pam ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать PAM.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo PAM файл:
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