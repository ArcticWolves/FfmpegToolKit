@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\stabilizators\deshake.bat
rem
rem Стабилизация видео с использованием фильтра:
rem     deshake
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#deshake
rem
rem Архитектурная роль:
rem     Controller для встроенного фильтра deshake.
rem
rem Требования:
rem     - CONFIG_LOADED должен быть установлен.
rem     - INPUT_FILE должен содержать путь к входному файлу.
rem ============================================================

rem ------------------------------------------------------------
rem Проверка загрузки конфигурации
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

:MAIN_MENU
cls

echo ============================================================
echo                    Deshake Stabilization
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. Быстрая стабилизация
echo  2. Стандартная стабилизация (рекомендуется)
echo  3. Сильная стабилизация
echo  4. Пользовательские параметры
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите режим: "

if "%CHOICE%"=="1" goto PRESET_FAST
if "%CHOICE%"=="2" goto PRESET_STANDARD
if "%CHOICE%"=="3" goto PRESET_STRONG
if "%CHOICE%"=="4" goto CUSTOM_SETTINGS
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Пресеты
rem ============================================================

:PRESET_FAST
call "%PRESETS_DIR%\stabilizators\deshake_presset.bat" fast
if errorlevel 1 goto MAIN_MENU
goto RUN

:PRESET_STANDARD
call "%PRESETS_DIR%\stabilizators\deshake_presset.bat" standard
if errorlevel 1 goto MAIN_MENU
goto RUN

:PRESET_STRONG
call "%PRESETS_DIR%\stabilizators\deshake_presset.bat" strong
if errorlevel 1 goto MAIN_MENU
goto RUN


rem ============================================================
rem Пользовательские параметры
rem ============================================================
:CUSTOM_SETTINGS
cls

echo ============================================================
echo               Пользовательские параметры
echo ============================================================
echo.

set "RX=16"
set "RY=16"
set "BLOCKSIZE=8"
set "CONTRAST=125"
set "EDGE=mirror"
set "SEARCH=exhaustive"

set /p "RX=Максимальное смещение по X [16]: "
if not defined RX set "RX=16"

set /p "RY=Максимальное смещение по Y [16]: "
if not defined RY set "RY=16"

set /p "BLOCKSIZE=Размер блока [8]: "
if not defined BLOCKSIZE set "BLOCKSIZE=8"

set /p "CONTRAST=Минимальный контраст [125]: "
if not defined CONTRAST set "CONTRAST=125"

echo.
echo Режимы edge:
echo   blank - заполняет края черным цветом
echo   original - заполняет края пикселями из оригинального видео
echo   clamp - повторяет крайние пиксели
echo   mirror - зеркально отражает видео по краям
echo.
set /p "EDGE=Обработка краев [mirror]: "
if not defined EDGE set "EDGE=mirror"

echo.
echo Режимы search:
echo   exhaustive
echo   less
echo.
set /p "SEARCH=Стратегия поиска [exhaustive]: "
if not defined SEARCH set "SEARCH=exhaustive"

set "DESHAKE_FILTER=deshake=rx=%RX%:ry=%RY%:blocksize=%BLOCKSIZE%:contrast=%CONTRAST%:edge=%EDGE%:search=%SEARCH%"
goto RUN


rem ============================================================
rem Выполнение стабилизации
rem ============================================================
:RUN
cls

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

set "OUTPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_SUFFIX=deshake"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

set "EDIT_ALLOW_AUDIO_COPY=1"
call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
if errorlevel 1 goto MAIN_MENU

echo ============================================================
echo                    Выполнение
echo ============================================================
echo.
echo Фильтр:
echo %DESHAKE_FILTER%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%DESHAKE_FILTER%" ^
-c:v %EDIT_VIDEO_CODEC% %EDIT_VIDEO_OPTIONS% ^
-c:a %EDIT_AUDIO_CODEC% %EDIT_AUDIO_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Стабилизация завершилась с ошибкой.
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
    set "PLAY_CHOICE="
    set /p "PLAY_CHOICE=Открыть результат в FFplay? (Y/N): "
    if /i "!PLAY_CHOICE!"=="Y" (
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
