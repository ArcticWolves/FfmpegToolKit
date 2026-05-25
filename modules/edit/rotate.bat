@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\rotate.bat
rem
rem Поворот и отражение видео.
rem
rem Используемые фильтры FFmpeg:
rem   - transpose  : поворот на 90°/180°/270°
rem   - hflip      : отражение по горизонтали
rem   - vflip      : отражение по вертикали
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#transpose
rem
rem Архитектурная роль:
rem   Специализированный модуль раздела Edit.
rem
rem Вход:
rem   INPUT_FILE должен быть задан заранее.
rem
rem Выход:
rem   output\{ИмяФайла}_rotate_{preset}.{ext}
rem Обрати внимание на важный нюанс: варианты «90° против часовой стрелки» и «270° по часовой стрелке» 
rem визуально эквивалентны и используют один и тот же фильтр transpose=2. Разница только в имени выходного файла.
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
echo                        Поворот видео
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. Повернуть на 90° по часовой стрелке
echo  2. Повернуть на 90° против часовой стрелки
echo  3. Повернуть на 180°
echo  4. Повернуть на 270° по часовой стрелке
echo  5. Отразить по горизонтали
echo  6. Отразить по вертикали
echo  7. Пользовательский фильтр
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto ROTATE_90_CW
if "%CHOICE%"=="2" goto ROTATE_90_CCW
if "%CHOICE%"=="3" goto ROTATE_180
if "%CHOICE%"=="4" goto ROTATE_270_CW
if "%CHOICE%"=="5" goto FLIP_HORIZONTAL
if "%CHOICE%"=="6" goto FLIP_VERTICAL
if "%CHOICE%"=="7" goto CUSTOM_FILTER
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Готовые пресеты
rem ============================================================

:ROTATE_90_CW
set "VIDEO_FILTER=transpose=1"
set "SUFFIX=rotate_90_cw"
goto RUN

:ROTATE_90_CCW
set "VIDEO_FILTER=transpose=2"
set "SUFFIX=rotate_90_ccw"
goto RUN

:ROTATE_180
set "VIDEO_FILTER=transpose=1,transpose=1"
set "SUFFIX=rotate_180"
goto RUN

:ROTATE_270_CW
set "VIDEO_FILTER=transpose=2"
set "SUFFIX=rotate_270_cw"
goto RUN

:FLIP_HORIZONTAL
set "VIDEO_FILTER=hflip"
set "SUFFIX=hflip"
goto RUN

:FLIP_VERTICAL
set "VIDEO_FILTER=vflip"
set "SUFFIX=vflip"
goto RUN


rem ============================================================
rem Пользовательский фильтр
rem ============================================================
:CUSTOM_FILTER
cls

echo ============================================================
echo                 Пользовательский фильтр
echo ============================================================
echo.
echo Примеры:
echo   transpose=1
echo   transpose=2
echo   transpose=1,transpose=1
echo   hflip
echo   vflip
echo   transpose=1,hflip
echo.

set "VIDEO_FILTER="
set /p "VIDEO_FILTER=Введите video filter: "

if not defined VIDEO_FILTER (
    echo.
    echo [ERROR] Фильтр не введён.
    echo.
    pause
    goto MAIN_MENU
)

set "SUFFIX=custom_rotate"
goto RUN


rem ============================================================
rem Выполнение обработки
rem ============================================================
:RUN
cls

set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%SUFFIX%%INPUT_EXT%"

echo ============================================================
echo                    Поворот видео
echo ============================================================
echo.
echo Видео фильтр:
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
