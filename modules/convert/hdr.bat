@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\hdr.bat
rem
rem Извлечение кадра из видео или конвертация изображения в
rem Radiance HDR (.hdr).
rem
rem Формат:
rem   Radiance RGBE HDR
rem
rem Особенности:
rem   - Хранит HDR-данные в формате RGBE.
rem   - Используется для environment maps и light probes.
rem   - Поддерживается Blender, Godot, Unity, Unreal Engine.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Pixel Format
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#hdr
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
rem Имя входного файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Параметры по умолчанию
rem ------------------------------------------------------------
set "TIMECODE=00:00:00"
set "PIX_FMT=gbrpf32le"

:MAIN_MENU
cls

echo ============================================================
echo                     Radiance HDR
echo ============================================================
echo.
echo Входной файл:
echo   %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать Pixel Format
echo  3. Создать HDR
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_PIXEL_FORMAT
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


rem ============================================================
rem Установка таймкода
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
rem Выбор Pixel Format
rem ============================================================
:SET_PIXEL_FORMAT
cls

echo ============================================================
echo                      Pixel Format
echo ============================================================
echo.
echo  1. gbrpf32le   (32-bit float RGB) [Recommended]
echo  2. gbrapf32le  (32-bit float RGBA)
echo  3. rgb48le     (16-bit integer RGB)
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
if "%FMT_CHOICE%"=="3" set "PIX_FMT=rgb48le"
if "%FMT_CHOICE%"=="3" goto MAIN_MENU
if "%FMT_CHOICE%"=="0" goto MAIN_MENU

goto SET_PIXEL_FORMAT


rem ============================================================
rem Создание HDR
rem ============================================================
:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=hdr"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание HDR
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
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
-c:v hdr ^
-pix_fmt %PIX_FMT% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать HDR.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo HDR файл:
echo   %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "OPEN_RESULT="
    set /p "OPEN_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%OPEN_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
