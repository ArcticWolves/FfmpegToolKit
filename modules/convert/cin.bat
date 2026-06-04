@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\cin.bat
rem
rem Извлечение кадра из видео или конвертация изображения в
rem Cineon (.cin).
rem
rem Формат:
rem   Kodak Cineon
rem
rem Особенности:
rem   - Используется в киноиндустрии.
rem   - Обычно хранит 10-bit log данные.
rem   - Предшественник DPX.
rem   - Подходит для film scanning и color grading.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Pixel Format
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#cineon
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
set "PIX_FMT=gbrp10le"

:MAIN_MENU
cls

echo ============================================================
echo                         Cineon
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
echo  3. Создать CIN
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
echo.
pause
goto MAIN_MENU


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


:SET_PIXEL_FORMAT
cls

echo ============================================================
echo                      Pixel Format
echo ============================================================
echo.
echo  1. gbrp10le   (10-bit RGB Log) [Recommended]
echo  2. rgb48le    (16-bit RGB)
echo  3. rgb24      (8-bit RGB)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "FMT_CHOICE="
set /p "FMT_CHOICE=Выберите формат: "

if "%FMT_CHOICE%"=="1" set "PIX_FMT=gbrp10le"
if "%FMT_CHOICE%"=="1" goto MAIN_MENU
if "%FMT_CHOICE%"=="2" set "PIX_FMT=rgb48le"
if "%FMT_CHOICE%"=="2" goto MAIN_MENU
if "%FMT_CHOICE%"=="3" set "PIX_FMT=rgb24"
if "%FMT_CHOICE%"=="3" goto MAIN_MENU
if "%FMT_CHOICE%"=="0" goto MAIN_MENU

goto SET_PIXEL_FORMAT


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=cin"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                   Создание Cineon
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
-c:v cineon ^
-pix_fmt %PIX_FMT% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать Cineon файл.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo CIN файл:
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
