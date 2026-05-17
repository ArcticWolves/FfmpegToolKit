@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\speed.bat
rem
rem Изменение скорости воспроизведения видео и аудио.
rem
rem Используемые фильтры:
rem   - setpts   : изменение скорости видео
rem   - atempo   : изменение скорости аудио
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-filters.html#setpts_002c-asetpts
rem   https://ffmpeg.org/ffmpeg-filters.html#atempo
rem
rem Особенности:
rem   - setpts использует формулу:
rem         PTS = PTS / SPEED
rem
rem   - atempo поддерживает диапазон:
rem         0.5 .. 100.0
rem
rem   - Для совместимости и предсказуемого поведения
rem     мы разбиваем значения вне диапазона 0.5..2.0
rem     на цепочку фильтров atempo.
rem
rem Примеры:
rem   2.0x  -> atempo=2.0
rem   4.0x  -> atempo=2.0,atempo=2.0
rem   0.25x -> atempo=0.5,atempo=0.5
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
echo                 Изменение скорости
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. 0.25x  (очень медленно)
echo  2. 0.50x  (в 2 раза медленнее)
echo  3. 0.75x
echo  4. 1.00x  (без изменений)
echo  5. 1.25x
echo  6. 1.50x
echo  7. 2.00x  (в 2 раза быстрее)
echo  8. 4.00x  (в 4 раза быстрее)
echo  9. Пользовательское значение
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите коэффициент скорости: "

if "%CHOICE%"=="1" set "SPEED=0.25" & goto BUILD_FILTERS
if "%CHOICE%"=="2" set "SPEED=0.50" & goto BUILD_FILTERS
if "%CHOICE%"=="3" set "SPEED=0.75" & goto BUILD_FILTERS
if "%CHOICE%"=="4" set "SPEED=1.00" & goto BUILD_FILTERS
if "%CHOICE%"=="5" set "SPEED=1.25" & goto BUILD_FILTERS
if "%CHOICE%"=="6" set "SPEED=1.50" & goto BUILD_FILTERS
if "%CHOICE%"=="7" set "SPEED=2.00" & goto BUILD_FILTERS
if "%CHOICE%"=="8" set "SPEED=4.00" & goto BUILD_FILTERS
if "%CHOICE%"=="9" goto CUSTOM_SPEED
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Пользовательский ввод скорости
rem ============================================================
:CUSTOM_SPEED
cls

echo ============================================================
echo              Пользовательская скорость
echo ============================================================
echo.
echo Примеры:
echo   0.25  - замедление в 4 раза
echo   0.50  - замедление в 2 раза
echo   1.00  - без изменений
echo   2.00  - ускорение в 2 раза
echo   10.0  - ускорение в 10 раз
echo.

set "SPEED="
set /p "SPEED=Введите коэффициент скорости: "

if not defined SPEED (
    echo.
    echo [ERROR] Значение не введено.
    echo.
    pause
    goto MAIN_MENU
)

goto BUILD_FILTERS


rem ============================================================
rem Формирование фильтров
rem ============================================================
:BUILD_FILTERS

rem Видео: setpts=PTS/SPEED
set "VIDEO_FILTER=setpts=PTS/%SPEED%"

rem Построение цепочки atempo
call :BuildAtempoChain "%SPEED%"
if errorlevel 1 (
    pause
    goto MAIN_MENU
)

set "AUDIO_FILTER=%ATEMPO_CHAIN%"

goto RUN


rem ============================================================
rem Выполнение обработки
rem ============================================================
:RUN
cls

set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_speed_%SPEED%x%INPUT_EXT%"

echo ============================================================
echo                Изменение скорости
echo ============================================================
echo.
echo Скорость:
echo %SPEED%x
echo.
echo Видео фильтр:
echo %VIDEO_FILTER%
echo.
echo Аудио фильтр:
echo %AUDIO_FILTER%
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
-filter:v "%VIDEO_FILTER%" ^
-filter:a "%AUDIO_FILTER%" ^
-c:v libx264 ^
-crf 18 ^
-preset medium ^
-c:a aac ^
-b:a 192k ^
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
rem BuildAtempoChain
rem
rem Формирует цепочку фильтров atempo.
rem
rem Примеры:
rem   SPEED=4.0   -> atempo=2.0,atempo=2.0
rem   SPEED=0.25  -> atempo=0.5,atempo=0.5
rem   SPEED=1.5   -> atempo=1.5
rem ============================================================
:BuildAtempoChain
setlocal EnableDelayedExpansion

set "VALUE=%~1"

if not defined VALUE (
    echo.
    echo [ERROR] Не задан коэффициент скорости.
    endlocal & exit /b 1
)

rem Используем PowerShell для корректного разбиения коэффициента
for /f %%I in ('
    powershell -NoProfile -Command ^
    "$speed=[double]'%VALUE%';" ^
    "if($speed -le 0){ exit 1 }" ^
    "$parts=@();" ^
    "while($speed -gt 2.0){ $parts += 'atempo=2.0'; $speed /= 2.0 }" ^
    "while($speed -lt 0.5){ $parts += 'atempo=0.5'; $speed /= 0.5 }" ^
    "$parts += ('atempo=' + $speed.ToString([System.Globalization.CultureInfo]::InvariantCulture));" ^
    "$parts -join ','"
') do (
    set "CHAIN=%%I"
)

if not defined CHAIN (
    echo.
    echo [ERROR] Не удалось сформировать atempo.
    endlocal & exit /b 1
)

endlocal & (
    set "ATEMPO_CHAIN=%CHAIN%"
)
exit /b 0


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0