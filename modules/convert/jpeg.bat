@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\jpeg.bat
rem
rem Извлечение кадра из видео или конвертация изображения в JPEG.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Quality (2-31, меньше = лучше)
rem
rem Используемый кодек:
rem   mjpeg
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-codecs.html#mjpeg
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
set "QVALUE=2"
set "VIDEO_CODEC=mjpeg"

:MAIN_MENU
cls

echo ============================================================
echo                         JPEG
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Quality (-q:v):
echo   %QVALUE%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Указать качество JPEG
echo  3. Извлечь кадр
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_QUALITY
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


:SET_QUALITY
cls
echo.
echo JPEG quality:
echo   2  = максимальное качество
echo   5  = очень хорошее качество
echo   10 = хорошее качество
echo   31 = минимальное качество
echo.
set "NEW_QVALUE="
set /p "NEW_QVALUE=Введите значение [%QVALUE%]: "

if defined NEW_QVALUE (
    set "QVALUE=%NEW_QVALUE%"
)

goto MAIN_MENU


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=jpg"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                  Извлечение JPEG
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Quality:
echo   %QVALUE%
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
-c:v %VIDEO_CODEC% ^
-q:v %QVALUE% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось извлечь JPEG.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo JPEG файл:
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
