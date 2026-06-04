@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\watermark.bat
rem
rem Наложение водяного знака (изображение или видео).
rem
rem Используемые фильтры:
rem   - overlay
rem
rem Поддерживаемые возможности:
rem   1. Водяной знак из PNG/JPG/WebP/BMP
rem   2. Водяной знак из видео (с альфа-каналом)
rem   3. Выбор позиции
rem   4. Настройка отступов
rem   5. Масштабирование водяного знака
rem   6. Настройка прозрачности
rem   7. Включение на определённом интервале времени
rem   8. Зацикливание изображения
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#overlay
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
rem Получение имени входного файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

:ASK_WATERMARK_FILE
cls
echo ============================================================
echo                    Водяной знак
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Укажите путь к изображению или видео,
echo которое будет использовано как водяной знак.
echo.

set "WATERMARK_FILE="
set /p "WATERMARK_FILE=Файл водяного знака: "

if not defined WATERMARK_FILE (
    echo.
    echo [ERROR] Файл не указан.
    pause
    goto ASK_WATERMARK_FILE
)

if not exist "%WATERMARK_FILE%" (
    echo.
    echo [ERROR] Файл не найден:
    echo         %WATERMARK_FILE%
    pause
    goto ASK_WATERMARK_FILE
)

for %%F in ("%WATERMARK_FILE%") do (
    set "WATERMARK_NAME=%%~nF"
)

goto MAIN_MENU


:MAIN_MENU
cls
echo ============================================================
echo                    Водяной знак
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Водяной знак:
echo %WATERMARK_FILE%
echo.
echo ============================================================
echo.
echo  1. Верхний левый угол
echo  2. Верхний правый угол
echo  3. Нижний левый угол
echo  4. Нижний правый угол
echo  5. По центру
echo  6. Пользовательская позиция
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите позицию: "

if "%CHOICE%"=="1" goto POS_TOP_LEFT
if "%CHOICE%"=="2" goto POS_TOP_RIGHT
if "%CHOICE%"=="3" goto POS_BOTTOM_LEFT
if "%CHOICE%"=="4" goto POS_BOTTOM_RIGHT
if "%CHOICE%"=="5" goto POS_CENTER
if "%CHOICE%"=="6" goto POS_CUSTOM
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


rem ============================================================
rem Предустановленные позиции
rem ============================================================
:POS_TOP_LEFT
set "POS_X=MARGIN_X"
set "POS_Y=MARGIN_Y"
goto ASK_OPTIONS

:POS_TOP_RIGHT
set "POS_X=main_w-overlay_w-MARGIN_X"
set "POS_Y=MARGIN_Y"
goto ASK_OPTIONS

:POS_BOTTOM_LEFT
set "POS_X=MARGIN_X"
set "POS_Y=main_h-overlay_h-MARGIN_Y"
goto ASK_OPTIONS

:POS_BOTTOM_RIGHT
set "POS_X=main_w-overlay_w-MARGIN_X"
set "POS_Y=main_h-overlay_h-MARGIN_Y"
goto ASK_OPTIONS

:POS_CENTER
set "POS_X=(main_w-overlay_w)/2"
set "POS_Y=(main_h-overlay_h)/2"
goto ASK_OPTIONS


rem ============================================================
rem Пользовательская позиция
rem ============================================================
:POS_CUSTOM
cls
echo ============================================================
echo               Пользовательская позиция
echo ============================================================
echo.
echo Примеры:
echo   x=100
echo   y=50
echo.
echo Можно использовать выражения FFmpeg:
echo   main_w-overlay_w-20
echo   (main_w-overlay_w)/2
echo.

set "POS_X="
set /p "POS_X=X: "

set "POS_Y="
set /p "POS_Y=Y: "

if not defined POS_X set "POS_X=10"
if not defined POS_Y set "POS_Y=10"

goto ASK_OPTIONS


rem ============================================================
rem Дополнительные параметры
rem ============================================================
:ASK_OPTIONS
cls
echo ============================================================
echo               Дополнительные параметры
echo ============================================================
echo.

set "MARGIN_X=10"
set "MARGIN_Y=10"
set "SCALE_PERCENT=100"
set "OPACITY=1.0"
set "ENABLE_TIME=0"
set "START_TIME=0"
set "END_TIME=0"

set /p "MARGIN_X=Отступ по X [10]: "
if not defined MARGIN_X set "MARGIN_X=10"

set /p "MARGIN_Y=Отступ по Y [10]: "
if not defined MARGIN_Y set "MARGIN_Y=10"

set /p "SCALE_PERCENT=Размер водяного знака (%%) [100]: "
if not defined SCALE_PERCENT set "SCALE_PERCENT=100"

set /p "OPACITY=Прозрачность (0.0 - 1.0) [1.0]: "
if not defined OPACITY set "OPACITY=1.0"

echo.
set "TIME_CHOICE="
set /p "TIME_CHOICE=Ограничить по времени? (Y/N): "

if /i "%TIME_CHOICE%"=="Y" (
    set "ENABLE_TIME=1"

    set /p "START_TIME=Начало (сек) [0]: "
    if not defined START_TIME set "START_TIME=0"

    set /p "END_TIME=Конец (сек): "

    if not defined END_TIME (
        echo.
        echo [ERROR] Не указано время окончания.
        pause
        goto ASK_OPTIONS
    )
)

goto BUILD_FILTER


rem ============================================================
rem Формирование filter_complex
rem ============================================================
:BUILD_FILTER

rem ------------------------------------------------------------
rem Замена MARGIN_X/MARGIN_Y в позиционных выражениях
rem ------------------------------------------------------------
set "FINAL_X=%POS_X:MARGIN_X=%MARGIN_X%%"
set "FINAL_X=%FINAL_X:MARGIN_Y=%MARGIN_Y%%"

set "FINAL_Y=%POS_Y:MARGIN_X=%MARGIN_X%%"
set "FINAL_Y=%FINAL_Y:MARGIN_Y=%MARGIN_Y%%"

rem ------------------------------------------------------------
rem Масштаб
rem scale=iw*0.50:-1
rem ------------------------------------------------------------
set "SCALE_EXPR=iw*%SCALE_PERCENT%/100:-1"

rem ------------------------------------------------------------
rem Прозрачность
rem format=rgba,colorchannelmixer=aa=0.5
rem ------------------------------------------------------------
set "WM_FILTER=[1:v]scale=%SCALE_EXPR%,format=rgba,colorchannelmixer=aa=%OPACITY%[wm]"

rem ------------------------------------------------------------
rem Overlay
rem ------------------------------------------------------------
set "OVERLAY_FILTER=[0:v][wm]overlay=%FINAL_X%:%FINAL_Y%"

if "%ENABLE_TIME%"=="1" (
    set "OVERLAY_FILTER=%OVERLAY_FILTER%:enable='between(t,%START_TIME%,%END_TIME%)'"
)

set "FILTER_COMPLEX=%WM_FILTER%;%OVERLAY_FILTER%"

goto RUN


rem ============================================================
rem Выполнение обработки
rem ============================================================
:RUN
cls

set "OUTPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_SUFFIX=watermark"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

set "EDIT_ALLOW_AUDIO_COPY=1"
call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
if errorlevel 1 goto MAIN_MENU

echo ============================================================
echo                 Наложение водяного знака
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Водяной знак:
echo %WATERMARK_FILE%
echo.
echo Размер:
echo %SCALE_PERCENT%%%
echo.
echo Прозрачность:
echo %OPACITY%
echo.
echo Позиция:
echo X = %FINAL_X%
echo Y = %FINAL_Y%
echo.
if "%ENABLE_TIME%"=="1" (
    echo Интервал:
    echo %START_TIME% - %END_TIME% сек.
    echo.
)
echo Filter Complex:
echo %FILTER_COMPLEX%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-stream_loop -1 -i "%WATERMARK_FILE%" ^
-filter_complex "%FILTER_COMPLEX%" ^
-map 0:v ^
-map 0:a? ^
-c:v %EDIT_VIDEO_CODEC% %EDIT_VIDEO_OPTIONS% ^
-c:a %EDIT_AUDIO_CODEC% %EDIT_AUDIO_OPTIONS% ^
-shortest ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Обработка завершилась с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%PLAY_RESULT%"=="Y" (
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
