@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\exr.bat
rem
rem Извлечение кадра из видео или конвертация изображения в
rem OpenEXR (.exr).
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Compression Type
rem   - Pixel Format
rem
rem Особенности OpenEXR:
rem   - Высокая динамическая глубина (HDR).
rem   - 16-bit half float и 32-bit float.
rem   - Используется в VFX и CGI.
rem   - Поддерживает alpha channel.
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#exr
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
set "COMPRESSION=zip16"
set "PIX_FMT=gbrpf32le"

:MAIN_MENU
cls

echo ============================================================
echo                        OpenEXR
echo ============================================================
echo.
echo Входной файл:
echo   %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Compression:
echo   %COMPRESSION%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать compression
echo  3. Выбрать pixel format
echo  4. Создать EXR
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_COMPRESSION
if "%CHOICE%"=="3" goto SET_PIXEL_FORMAT
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


:SET_COMPRESSION
cls

echo ============================================================
echo                     EXR Compression
echo ============================================================
echo.
echo  1. none
echo  2. rle
echo  3. zip1
echo  4. zip16 (рекомендуется)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "COMP_CHOICE="
set /p "COMP_CHOICE=Выберите compression: "

if "%COMP_CHOICE%"=="1" set "COMPRESSION=none"
if "%COMP_CHOICE%"=="1" goto MAIN_MENU
if "%COMP_CHOICE%"=="2" set "COMPRESSION=rle"
if "%COMP_CHOICE%"=="2" goto MAIN_MENU
if "%COMP_CHOICE%"=="3" set "COMPRESSION=zip1"
if "%COMP_CHOICE%"=="3" goto MAIN_MENU
if "%COMP_CHOICE%"=="4" set "COMPRESSION=zip16"
if "%COMP_CHOICE%"=="4" goto MAIN_MENU
if "%COMP_CHOICE%"=="0" goto MAIN_MENU

goto SET_COMPRESSION


:SET_PIXEL_FORMAT
cls

echo ============================================================
echo                      Pixel Format
echo ============================================================
echo.
echo  1. gbrpf32le      (32-bit float RGB)
echo  2. gbrapf32le     (32-bit float RGBA)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "FMT_CHOICE="
set /p "FMT_CHOICE=Выберите формат: "

if "%FMT_CHOICE%"=="1" set "PIX_FMT=gbrpf32le"
if "%FMT_CHOICE%"=="1" goto MAIN_MENU
if "%FMT_CHOICE%"=="2" set "PIX_FMT=gbrapf32le"
if "%FMT_CHOICE%"=="2" goto MAIN_MENU
if "%FMT_CHOICE%"=="0" goto MAIN_MENU

goto SET_PIXEL_FORMAT


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=exr"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание OpenEXR
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Compression:
echo   %COMPRESSION%
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
-c:v exr ^
-compression %COMPRESSION% ^
-format float ^
-pix_fmt %PIX_FMT% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать EXR.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo EXR файл:
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
