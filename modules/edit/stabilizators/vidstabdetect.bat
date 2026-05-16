@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\stabilizators\vidstabdetect.bat
::
:: Первый проход стабилизации с использованием фильтра:
::     vidstabdetect
::
:: Назначение:
::   Анализирует движение камеры и сохраняет данные
::   трансформации в файл .trf.
::
:: Выходной файл:
::   %TRANSFORMS_DIR%\{ИмяВидео}.trf
::
:: Официальная документация:
:: https://ffmpeg.org/ffmpeg-filters.html#vidstabdetect
:: ============================================================

:: ------------------------------------------------------------
:: Проверка конфигурации
:: ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: Проверка входного файла
:: ------------------------------------------------------------
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

:: ------------------------------------------------------------
:: Проверка поддержки vidstabdetect
:: ------------------------------------------------------------
"%FFMPEG%" -hide_banner -filters | findstr /i "vidstabdetect" >nul
if errorlevel 1 (
    echo.
    echo [ERROR] Фильтр vidstabdetect не найден в вашей сборке FFmpeg.
    echo [ERROR] Требуется сборка с поддержкой libvidstab.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                     VidStab Detect
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo ============================================================
echo.
echo  1. Быстрый анализ
echo  2. Стандартный анализ (рекомендуется)
echo  3. Точный анализ
echo  4. Пользовательские параметры
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите режим анализа: "

if "%CHOICE%"=="1" goto PRESET_FAST
if "%CHOICE%"=="2" goto PRESET_STANDARD
if "%CHOICE%"=="3" goto PRESET_ACCURATE
if "%CHOICE%"=="4" goto CUSTOM_SETTINGS
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:: ============================================================
:: Пресеты
:: ============================================================

:PRESET_FAST
set "SHAKINESS=4"
set "ACCURACY=6"
set "STEPSIZE=6"
set "MINCONTRAST=0.25"
goto BUILD_FILTER

:PRESET_STANDARD
set "SHAKINESS=5"
set "ACCURACY=9"
set "STEPSIZE=6"
set "MINCONTRAST=0.30"
goto BUILD_FILTER

:PRESET_ACCURATE
set "SHAKINESS=8"
set "ACCURACY=15"
set "STEPSIZE=4"
set "MINCONTRAST=0.30"
goto BUILD_FILTER


:: ============================================================
:: Пользовательские параметры
:: ============================================================
:CUSTOM_SETTINGS
cls

echo ============================================================
echo               Пользовательские параметры
echo ============================================================
echo.

set "SHAKINESS=5"
set "ACCURACY=9"
set "STEPSIZE=6"
set "MINCONTRAST=0.30"

set /p "SHAKINESS=Shakiness (1-10) [5]: "
if not defined SHAKINESS set "SHAKINESS=5"

set /p "ACCURACY=Accuracy (1-15) [9]: "
if not defined ACCURACY set "ACCURACY=9"

set /p "STEPSIZE=Stepsize [6]: "
if not defined STEPSIZE set "STEPSIZE=6"

set /p "MINCONTRAST=Mincontrast [0.30]: "
if not defined MINCONTRAST set "MINCONTRAST=0.30"

goto BUILD_FILTER


:: ============================================================
:: Формирование фильтра
:: ============================================================
:BUILD_FILTER

for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

set "TRANSFORM_FILE=%TRANSFORMS_DIR%\%INPUT_NAME%.trf"

set "VIDSTAB_FILTER=vidstabdetect=result='%TRANSFORM_FILE%':shakiness=%SHAKINESS%:accuracy=%ACCURACY%:stepsize=%STEPSIZE%:mincontrast=%MINCONTRAST%"

goto RUN


:: ============================================================
:: Выполнение анализа
:: ============================================================
:RUN
cls

echo ============================================================
echo                  Анализ движения камеры
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Файл трансформации:
echo %TRANSFORM_FILE%
echo.
echo Параметры:
echo   shakiness   = %SHAKINESS%
echo   accuracy    = %ACCURACY%
echo   stepsize    = %STEPSIZE%
echo   mincontrast = %MINCONTRAST%
echo.
echo Фильтр:
echo %VIDSTAB_FILTER%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

if exist "%TRANSFORM_FILE%" del /q "%TRANSFORM_FILE%"

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%VIDSTAB_FILTER%" ^
-an ^
-f null NUL

if errorlevel 1 (
    echo.
    echo [ERROR] Анализ завершился с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)

if not exist "%TRANSFORM_FILE%" (
    echo.
    echo [ERROR] Файл трансформации не был создан.
    echo.
    pause
    goto MAIN_MENU
)

:: ------------------------------------------------------------
:: Успешное завершение анализа
:: ------------------------------------------------------------
echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo Файл трансформации успешно создан:
echo %TRANSFORM_FILE%
echo.
echo Следующий шаг:
echo   Применение стабилизации через vidstabtransform.
echo.

set "RUN_TRANSFORM="
set /p "RUN_TRANSFORM=Запустить vidstabtransform сейчас? (Y/N): "

if /i "%RUN_TRANSFORM%"=="Y" (
    if exist "%MODULES_DIR%\edit\stabilizators\vidstabtransform.bat" (
        call "%MODULES_DIR%\edit\stabilizators\vidstabtransform.bat"
    ) else (
        echo.
        echo [ERROR] Не найден модуль:
        echo         %MODULES_DIR%\edit\stabilizators\vidstabtransform.bat
        echo.
        pause
    )
) else (
    echo.
    echo Применение стабилизации отложено.
    echo.
    pause
)

goto MAIN_MENU

:: ============================================================
:: Выход
:: ============================================================
:EXIT_MODULE
endlocal
exit /b 0