@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\pnm.bat
rem
rem Конвертация в PNM (Portable Any Map).
rem
rem Форматы PNM:
rem   - PBM (1-bit bitmap)
rem   - PGM (grayscale)
rem   - PPM (RGB)
rem
rem Пользователь выбирает:
rem   - Таймкод
rem   - Подформат PNM
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
rem Получение имени файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "TIMECODE=00:00:00"
set "PNM_TYPE=ppm"
set "PIX_FMT=rgb24"
set "EXTENSION=pnm"

:MAIN_MENU
cls

echo ============================================================
echo                          PNM
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Формат:
echo   %PNM_TYPE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать подформат
echo  3. Создать PNM
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_FORMAT
if "%CHOICE%"=="3" goto RUN
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


:SET_FORMAT
cls

echo ============================================================
echo                    Подформат PNM
echo ============================================================
echo.
echo  1. PBM (1-bit black/white)
echo  2. PGM (grayscale)
echo  3. PPM (RGB)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "FORMAT_CHOICE="
set /p "FORMAT_CHOICE=Выберите формат: "

if "%FORMAT_CHOICE%"=="1" (
    set "PNM_TYPE=pbm"
    set "PIX_FMT=monow"
    goto MAIN_MENU
)

if "%FORMAT_CHOICE%"=="2" (
    set "PNM_TYPE=pgm"
    set "PIX_FMT=gray"
    goto MAIN_MENU
)

if "%FORMAT_CHOICE%"=="3" (
    set "PNM_TYPE=ppm"
    set "PIX_FMT=rgb24"
    goto MAIN_MENU
)

if "%FORMAT_CHOICE%"=="0" goto MAIN_MENU

goto SET_FORMAT


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=pnm"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание PNM
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Формат:
echo   %PNM_TYPE%
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
-f image2 ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать PNM.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo PNM файл:
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
