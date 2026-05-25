@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\crop.bat
rem
rem Обрезка видео с использованием фильтра:
rem     crop
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#crop
rem
rem Формула:
rem     crop=out_w:out_h:x:y
rem
rem Где:
rem     out_w - ширина области
rem     out_h - высота области
rem     x     - смещение по X
rem     y     - смещение по Y
rem
rem Поддерживаемые режимы:
rem   1. Центрированная обрезка
rem   2. Удалить поля сверху/снизу
rem   3. Удалить поля слева/справа
rem   4. Произвольная область
rem   5. Обрезка по процентам
rem   6. Квадрат из центра
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

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

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

:MAIN_MENU
cls

echo ============================================================
echo                         Crop
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. Центрированная обрезка
echo  2. Обрезать сверху и снизу
echo  3. Обрезать слева и справа
echo  4. Произвольная область
echo  5. Обрезка по процентам
echo  6. Квадрат из центра
echo.
echo  0. Назад

echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите режим: "

if "%CHOICE%"=="1" goto CENTER_CROP
if "%CHOICE%"=="2" goto CROP_TOP_BOTTOM
if "%CHOICE%"=="3" goto CROP_LEFT_RIGHT
if "%CHOICE%"=="4" goto CUSTOM_CROP
if "%CHOICE%"=="5" goto PERCENT_CROP
if "%CHOICE%"=="6" goto CENTER_SQUARE
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:CENTER_CROP
cls

echo ============================================================
echo                 Центрированная обрезка
echo ============================================================
echo.

set "WIDTH="
set "HEIGHT="

set /p "WIDTH=Введите ширину области: "
set /p "HEIGHT=Введите высоту области: "

if not defined WIDTH goto INVALID_INPUT
if not defined HEIGHT goto INVALID_INPUT

set "VIDEO_FILTER=crop=%WIDTH%:%HEIGHT%:(iw-%WIDTH%)/2:(ih-%HEIGHT%)/2"
goto RUN


:CROP_TOP_BOTTOM
cls

echo ============================================================
echo               Обрезка сверху и снизу
echo ============================================================
echo.

set "PIXELS="
set /p "PIXELS=Сколько пикселей удалить сверху и снизу: "

if not defined PIXELS goto INVALID_INPUT

set "VIDEO_FILTER=crop=iw:ih-2*%PIXELS%:0:%PIXELS%"
goto RUN


:CROP_LEFT_RIGHT
cls

echo ============================================================
echo               Обрезка слева и справа
echo ============================================================
echo.

set "PIXELS="
set /p "PIXELS=Сколько пикселей удалить слева и справа: "

if not defined PIXELS goto INVALID_INPUT

set "VIDEO_FILTER=crop=iw-2*%PIXELS%:ih:%PIXELS%:0"
goto RUN


:CUSTOM_CROP
cls

echo ============================================================
echo                 Произвольная область
echo ============================================================
echo.

set "WIDTH="
set "HEIGHT="
set "X="
set "Y="

set /p "WIDTH=Ширина области: "
set /p "HEIGHT=Высота области: "
set /p "X=Смещение X: "
set /p "Y=Смещение Y: "

if not defined WIDTH goto INVALID_INPUT
if not defined HEIGHT goto INVALID_INPUT
if not defined X set "X=0"
if not defined Y set "Y=0"

set "VIDEO_FILTER=crop=%WIDTH%:%HEIGHT%:%X%:%Y%"
goto RUN


:PERCENT_CROP
cls

echo ============================================================
echo                 Обрезка по процентам
echo ============================================================
echo.
echo Пример:
echo   10 = удалить по 10%% с каждой стороны.
echo.

set "PERCENT="
set /p "PERCENT=Введите процент: "

if not defined PERCENT goto INVALID_INPUT

set "VIDEO_FILTER=crop=iw*(1-%PERCENT%/100*2):ih*(1-%PERCENT%/100*2):iw*%PERCENT%/100:ih*%PERCENT%/100"
goto RUN


:CENTER_SQUARE
cls

echo ============================================================
echo                 Квадрат из центра
echo ============================================================
echo.

set "VIDEO_FILTER=crop=min(iw\,ih):min(iw\,ih):(iw-min(iw\,ih))/2:(ih-min(iw\,ih))/2"
goto RUN


:RUN
cls

set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_cropped%INPUT_EXT%"

echo ============================================================
echo                    Выполнение Crop
echo ============================================================
echo.
echo Фильтр:
echo %VIDEO_FILTER%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo ============================================================
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%VIDEO_FILTER%" ^
-c:v libopenh264 ^
-b:v 5M ^
-c:a copy ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Операция завершилась с ошибкой.
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

    if /i "!PLAY_RESULT!"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:INVALID_INPUT
echo.
echo [ERROR] Не введено обязательное значение.
echo.
pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
