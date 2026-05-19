@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\gif.bat
rem
rem Создание качественного GIF из видео.
rem
rem Используемый подход:
rem   1. palettegen  - генерация оптимальной палитры.
rem   2. paletteuse - применение палитры.
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#palettegen
rem https://ffmpeg.org/ffmpeg-filters.html#paletteuse
rem
rem Требования:
rem   - INPUT_FILE должен быть задан.
rem   - PALETTES_DIR должен быть определен в config.bat.
rem
rem Выход:
rem   output\{ИмяФайла}.gif
rem
rem Палитра:
rem   temp\palettes\{ИмяФайла}_palette.png
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
    echo [ERROR] Сначала выберите входной файл.
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
rem Проверка каталога палитр
rem ------------------------------------------------------------
if not defined PALETTES_DIR (
    echo.
    echo [ERROR] PALETTES_DIR не определен в config.bat.
    echo.
    pause
    exit /b 1
)

if not exist "%PALETTES_DIR%" (
    mkdir "%PALETTES_DIR%"
)

rem ------------------------------------------------------------
rem Получение имени файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

set "PALETTE_FILE=%PALETTES_DIR%\%INPUT_NAME%_palette.png"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%.gif"

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "START_TIME="
set "DURATION="
set "FPS=15"
set "WIDTH=640"
set "DITHER=sierra2_4a"

:MAIN_MENU
cls

echo ============================================================
echo                     Создание GIF
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Выходной GIF:
echo %OUTPUT_FILE%
echo.
echo Файл палитры:
echo %PALETTE_FILE%
echo.
echo ============================================================
echo.
echo Текущие параметры:
echo.
echo Начало      : %START_TIME%
echo Длительность: %DURATION%
echo FPS         : %FPS%
echo Ширина      : %WIDTH%
echo Dither      : %DITHER%
echo.
echo ============================================================
echo.
echo  1. Установить время начала (-ss)
echo  2. Установить длительность (-t)
echo  3. Установить FPS
echo  4. Установить ширину
echo  5. Выбрать dithering
echo  6. Создать GIF
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_START
if "%CHOICE%"=="2" goto SET_DURATION
if "%CHOICE%"=="3" goto SET_FPS
if "%CHOICE%"=="4" goto SET_WIDTH
if "%CHOICE%"=="5" goto SET_DITHER
if "%CHOICE%"=="6" goto CREATE_GIF
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:SET_START
cls
echo.
echo Примеры:
echo   5
echo   00:00:05
echo   01:23:45
echo.
set /p "START_TIME=Введите время начала: "
goto MAIN_MENU


:SET_DURATION
cls
echo.
echo Примеры:
echo   3
echo   10
echo   00:00:03
echo.
set /p "DURATION=Введите длительность: "
goto MAIN_MENU


:SET_FPS
cls
echo.
echo Рекомендуемые значения:
echo   10
echo   15
echo   20
echo.
set /p "FPS=Введите FPS [15]: "
if not defined FPS set "FPS=15"
goto MAIN_MENU


:SET_WIDTH
cls
echo.
echo Рекомендуемые значения:
echo   320
echo   480
echo   640
echo   720
echo.
set /p "WIDTH=Введите ширину [640]: "
if not defined WIDTH set "WIDTH=640"
goto MAIN_MENU


:SET_DITHER
cls

echo ============================================================
echo                      Dithering
echo ============================================================
echo.
echo  1. sierra2_4a  (рекомендуется)
echo  2. sierra2
echo  3. floyd_steinberg
echo  4. bayer
echo  5. none
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "DITHER_CHOICE="
set /p "DITHER_CHOICE=Выберите алгоритм: "

if "%DITHER_CHOICE%"=="1" set "DITHER=sierra2_4a"
if "%DITHER_CHOICE%"=="2" set "DITHER=sierra2"
if "%DITHER_CHOICE%"=="3" set "DITHER=floyd_steinberg"
if "%DITHER_CHOICE%"=="4" set "DITHER=bayer"
if "%DITHER_CHOICE%"=="5" set "DITHER=none"

goto MAIN_MENU


:CREATE_GIF
cls

rem ------------------------------------------------------------
rem Формирование опций времени
rem ------------------------------------------------------------
set "TIME_OPTIONS="

if defined START_TIME (
    set "TIME_OPTIONS=!TIME_OPTIONS! -ss %START_TIME%"
)

if defined DURATION (
    set "TIME_OPTIONS=!TIME_OPTIONS! -t %DURATION%"
)

rem ------------------------------------------------------------
rem Формирование фильтров
rem ------------------------------------------------------------
set "PALETTE_FILTER=fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos,palettegen=stats_mode=diff"

set "GIF_FILTER=fps=%FPS%,scale=%WIDTH%:-1:flags=lanczos[x];[x][1:v]paletteuse=dither=%DITHER%"

echo ============================================================
echo                 Генерация палитры
echo ============================================================
echo.
echo %PALETTE_FILE%
echo.

if exist "%PALETTE_FILE%" del /q "%PALETTE_FILE%"

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
%TIME_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%PALETTE_FILTER%" ^
"%PALETTE_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать палитру.
    echo.
    pause
    goto MAIN_MENU
)

if not exist "%PALETTE_FILE%" (
    echo.
    echo [ERROR] Файл палитры не был создан.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                   Создание GIF
echo ============================================================
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
%TIME_OPTIONS% ^
-i "%INPUT_FILE%" ^
-i "%PALETTE_FILE%" ^
-lavfi "%GIF_FILTER%" ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать GIF.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo GIF создан:
echo %OUTPUT_FILE%
echo.
echo Палитра:
echo %PALETTE_FILE%
echo.

rem ------------------------------------------------------------
rem Предпросмотр
rem ------------------------------------------------------------
if "%HAS_FFPLAY%"=="1" (
    echo.
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть GIF в FFplay? (Y/N): "

    if /i "%PLAY_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

rem ------------------------------------------------------------
rem Удаление палитры
rem ------------------------------------------------------------
echo.
set "DELETE_PALETTE="
set /p "DELETE_PALETTE=Удалить файл палитры? (Y/N): "

if /i "%DELETE_PALETTE%"=="Y" (
    if exist "%PALETTE_FILE%" (
        del /q "%PALETTE_FILE%"

        if exist "%PALETTE_FILE%" (
            echo.
            echo [WARNING] Не удалось удалить файл палитры:
            echo %PALETTE_FILE%
        ) else (
            echo.
            echo Палитра успешно удалена.
        )
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0