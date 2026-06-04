@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\pbm.bat
rem
rem Извлечение кадра из видео или конвертация изображения в PBM.
rem
rem Формат:
rem   Portable Bitmap (.pbm)
rem
rem Особенности:
rem   - Черно-белое изображение (1 бит на пиксель).
rem   - Используется для масок, OCR и бинаризации.
rem   - Полностью lossless.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Порог бинаризации
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#pbm
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
set "THRESHOLD=0.5"

:MAIN_MENU
cls

echo ============================================================
echo                          PBM
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Порог бинаризации:
echo   %THRESHOLD%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Указать threshold (0.0 - 1.0)
echo  3. Создать PBM
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_THRESHOLD
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
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


:SET_THRESHOLD
cls
echo.
echo Примеры:
echo   0.1 = почти всё белое
echo   0.5 = стандартное значение
echo   0.9 = почти всё чёрное
echo.
set "NEW_THRESHOLD="
set /p "NEW_THRESHOLD=Введите threshold [%THRESHOLD%]: "

if defined NEW_THRESHOLD (
    set "THRESHOLD=%NEW_THRESHOLD%"
)

goto MAIN_MENU


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=pbm"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание PBM
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Threshold:
echo   %THRESHOLD%
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
-vf "format=gray,lut=y='if(gte(val\,255*%THRESHOLD%)\,255\,0)'" ^
-c:v pbm ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать PBM.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo PBM файл:
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
