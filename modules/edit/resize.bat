@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\resize.bat
rem
rem Изменение размера видео.
rem
rem Используемый фильтр:
rem   scale
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-filters.html#scale
rem
rem Поддерживаемые режимы:
rem   1. Готовые разрешения (480p, 720p, 1080p, 4K)
rem   2. Пользовательская ширина и высота
rem   3. Изменение только ширины (высота автоматически)
rem   4. Изменение только высоты (ширина автоматически)
rem   5. Масштабирование в процентах
rem   6. Сохранение пропорций
rem
rem Особенности:
rem   - -2 используется для автоматического расчёта размера
rem     с сохранением пропорций и выравниванием по чётному числу.
rem   - Можно выбрать алгоритм масштабирования.
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
rem Получение имени файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

:MAIN_MENU
cls

echo ============================================================
echo                    Изменение размера
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. 640x480     (480p)
echo  2. 1280x720    (720p)
echo  3. 1920x1080   (1080p)
echo  4. 2560x1440   (1440p)
echo  5. 3840x2160   (4K UHD)
echo.
echo  6. Пользовательская ширина и высота
echo  7. Только ширина  (сохранить пропорции)
echo  8. Только высота  (сохранить пропорции)
echo  9. Масштабировать в процентах
echo.
echo 10. Выбрать алгоритм масштабирования
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите режим: "

if "%CHOICE%"=="1" set "WIDTH=640"  & set "HEIGHT=480"  & goto BUILD_FILTER
if "%CHOICE%"=="2" set "WIDTH=1280" & set "HEIGHT=720"  & goto BUILD_FILTER
if "%CHOICE%"=="3" set "WIDTH=1920" & set "HEIGHT=1080" & goto BUILD_FILTER
if "%CHOICE%"=="4" set "WIDTH=2560" & set "HEIGHT=1440" & goto BUILD_FILTER
if "%CHOICE%"=="5" set "WIDTH=3840" & set "HEIGHT=2160" & goto BUILD_FILTER
if "%CHOICE%"=="6" goto CUSTOM_SIZE
if "%CHOICE%"=="7" goto WIDTH_ONLY
if "%CHOICE%"=="8" goto HEIGHT_ONLY
if "%CHOICE%"=="9" goto SCALE_PERCENT
if "%CHOICE%"=="10" goto SELECT_FLAGS
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Пользовательская ширина и высота
rem ============================================================
:CUSTOM_SIZE
cls

echo ============================================================
echo             Пользовательское разрешение
echo ============================================================
echo.

set "WIDTH="
set "HEIGHT="

set /p "WIDTH=Введите ширину: "
set /p "HEIGHT=Введите высоту: "

if not defined WIDTH (
    echo.
    echo [ERROR] Ширина не задана.
    pause
    goto MAIN_MENU
)

if not defined HEIGHT (
    echo.
    echo [ERROR] Высота не задана.
    pause
    goto MAIN_MENU
)

goto BUILD_FILTER


rem ============================================================
rem Изменение только ширины
rem ============================================================
:WIDTH_ONLY
cls

echo ============================================================
echo                  Только ширина
echo ============================================================
echo.
echo Высота будет вычислена автоматически.
echo.

set "WIDTH="
set /p "WIDTH=Введите ширину: "

if not defined WIDTH (
    echo.
    echo [ERROR] Ширина не задана.
    pause
    goto MAIN_MENU
)

set "HEIGHT=-2"
goto BUILD_FILTER


rem ============================================================
rem Изменение только высоты
rem ============================================================
:HEIGHT_ONLY
cls

echo ============================================================
echo                  Только высота
echo ============================================================
echo.
echo Ширина будет вычислена автоматически.
echo.

set "HEIGHT="
set /p "HEIGHT=Введите высоту: "

if not defined HEIGHT (
    echo.
    echo [ERROR] Высота не задана.
    pause
    goto MAIN_MENU
)

set "WIDTH=-2"
goto BUILD_FILTER


rem ============================================================
rem Масштабирование в процентах
rem ============================================================
:SCALE_PERCENT
cls

echo ============================================================
echo             Масштабирование в процентах
echo ============================================================
echo.
echo Примеры:
echo   50  = уменьшить в 2 раза
echo   200 = увеличить в 2 раза
echo.

set "PERCENT="
set /p "PERCENT=Введите процент: "

if not defined PERCENT (
    echo.
    echo [ERROR] Процент не задан.
    pause
    goto MAIN_MENU
)

set "SCALE_EXPRESSION=iw*%PERCENT%/100:ih*%PERCENT%/100"
goto BUILD_FILTER_EXPRESSION


rem ============================================================
rem Выбор алгоритма масштабирования
rem ============================================================
:SELECT_FLAGS
cls

echo ============================================================
echo            Алгоритм масштабирования
echo ============================================================
echo.
echo  1. bicubic   (по умолчанию)
echo  2. bilinear  (быстрее)
echo  3. lanczos   (высокое качество)
echo  4. spline    (высокое качество)
echo  5. neighbor  (без сглаживания, pixel art)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "FLAGS_CHOICE="
set /p "FLAGS_CHOICE=Выберите алгоритм: "

if "%FLAGS_CHOICE%"=="1" set "SCALE_FLAGS=bicubic"  & goto MAIN_MENU
if "%FLAGS_CHOICE%"=="2" set "SCALE_FLAGS=bilinear" & goto MAIN_MENU
if "%FLAGS_CHOICE%"=="3" set "SCALE_FLAGS=lanczos"  & goto MAIN_MENU
if "%FLAGS_CHOICE%"=="4" set "SCALE_FLAGS=spline"   & goto MAIN_MENU
if "%FLAGS_CHOICE%"=="5" set "SCALE_FLAGS=neighbor" & goto MAIN_MENU
if "%FLAGS_CHOICE%"=="0" goto MAIN_MENU

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto SELECT_FLAGS


rem ============================================================
rem Построение фильтра scale=W:H
rem ============================================================
:BUILD_FILTER
if not defined SCALE_FLAGS (
    set "SCALE_FLAGS=bicubic"
)

set "VIDEO_FILTER=scale=%WIDTH%:%HEIGHT%:flags=%SCALE_FLAGS%"
goto RUN


rem ============================================================
rem Построение фильтра scale=expression
rem ============================================================
:BUILD_FILTER_EXPRESSION
if not defined SCALE_FLAGS (
    set "SCALE_FLAGS=bicubic"
)

set "VIDEO_FILTER=scale=%SCALE_EXPRESSION%:flags=%SCALE_FLAGS%"
goto RUN


rem ============================================================
rem Выполнение обработки
rem ============================================================
:RUN
cls

set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_resized%INPUT_EXT%"

echo ============================================================
echo                 Изменение размера
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
