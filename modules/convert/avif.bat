@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\avif.bat
rem
rem Извлечение кадра из видео или конвертация изображения в AVIF.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Quality (CRF)
rem   - Speed (preset)
rem
rem Используемый кодек:
rem   libaom-av1
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#libaom_002dav1
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
set "CRF=28"
set "CPU_USED=4"

:MAIN_MENU
cls

echo ============================================================
echo                         AVIF
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo CRF:
echo   %CRF%
echo.
echo Speed (cpu-used):
echo   %CPU_USED%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Указать CRF
echo  3. Указать скорость кодирования
echo  4. Создать AVIF
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_CRF
if "%CHOICE%"=="3" goto SET_CPU_USED
if "%CHOICE%"=="4" goto RUN
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
rem Ввод CRF
rem ============================================================
:SET_CRF
cls

echo ============================================================
echo                          CRF
echo ============================================================
echo.
echo Рекомендуемые значения:
echo   20-25  = высокое качество
echo   28     = хороший баланс
echo   35+    = меньший размер
echo.
echo Текущее значение:
echo   %CRF%
echo.

set "NEW_CRF="
set /p "NEW_CRF=Введите CRF [%CRF%]: "

if defined NEW_CRF (
    set "CRF=%NEW_CRF%"
)

goto MAIN_MENU


rem ============================================================
rem Ввод cpu-used
rem ============================================================
:SET_CPU_USED
cls

echo ============================================================
echo                 Скорость кодирования
echo ============================================================
echo.
echo Диапазон:
echo   0 = самое медленное, лучшее качество
echo   8 = самое быстрое
echo.
echo Текущее значение:
echo   %CPU_USED%
echo.

set "NEW_CPU_USED="
set /p "NEW_CPU_USED=Введите cpu-used [%CPU_USED%]: "

if defined NEW_CPU_USED (
    set "CPU_USED=%NEW_CPU_USED%"
)

goto MAIN_MENU


rem ============================================================
rem Выполнение конвертации
rem ============================================================
:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%SAFE_TIMECODE%.avif"

cls
echo ============================================================
echo                   Создание AVIF
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo CRF:
echo   %CRF%
echo.
echo cpu-used:
echo   %CPU_USED%
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
-c:v libaom-av1 ^
-still-picture 1 ^
-crf %CRF% ^
-b:v 0 ^
-cpu-used %CPU_USED% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать AVIF.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo AVIF файл:
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