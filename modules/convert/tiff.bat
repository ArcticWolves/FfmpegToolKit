@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\tiff.bat
rem
rem Извлечение кадра из видео или конвертация изображения в TIFF.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Тип сжатия TIFF
rem
rem Используемый кодек:
rem   tiff
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#tiff
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
set "COMPRESSION=lzw"

:MAIN_MENU
cls

echo ============================================================
echo                          TIFF
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Сжатие:
echo   %COMPRESSION%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать тип сжатия
echo  3. Создать TIFF
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_COMPRESSION
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
rem Выбор типа сжатия
rem ============================================================
:SET_COMPRESSION
cls

echo ============================================================
echo                    Сжатие TIFF
echo ============================================================
echo.
echo  1. none     (без сжатия)
echo  2. lzw      (рекомендуется)
echo  3. deflate
echo  4. packbits
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "COMP_CHOICE="
set /p "COMP_CHOICE=Выберите тип сжатия: "

if "%COMP_CHOICE%"=="1" set "COMPRESSION=none"
if "%COMP_CHOICE%"=="1" goto MAIN_MENU
if "%COMP_CHOICE%"=="2" set "COMPRESSION=lzw"
if "%COMP_CHOICE%"=="2" goto MAIN_MENU
if "%COMP_CHOICE%"=="3" set "COMPRESSION=deflate"
if "%COMP_CHOICE%"=="3" goto MAIN_MENU
if "%COMP_CHOICE%"=="4" set "COMPRESSION=packbits"
if "%COMP_CHOICE%"=="4" goto MAIN_MENU
if "%COMP_CHOICE%"=="0" goto MAIN_MENU

goto SET_COMPRESSION


rem ============================================================
rem Выполнение конвертации
rem ============================================================
:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=tiff"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                   Создание TIFF
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Сжатие:
echo   %COMPRESSION%
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
-c:v tiff ^
-compression_algo %COMPRESSION% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать TIFF.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo TIFF файл:
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


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0
