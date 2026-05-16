@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\stabilizators\vidstab.bat
rem
rem Полностью автоматический двухпроходный режим стабилизации.
rem
rem Последовательно выполняет:
rem   1. vidstabdetect.bat
rem   2. vidstabtransform.bat
rem
rem Назначение:
rem   Предоставить пользователю один пункт меню
rem   "Стабилизировать видео", скрывая технические детали.
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
rem Проверка наличия модулей
rem ------------------------------------------------------------
set "VIDSTABDETECT_MODULE=%MODULES_DIR%\edit\stabilizators\vidstabdetect.bat"
set "VIDSTABTRANSFORM_MODULE=%MODULES_DIR%\edit\stabilizators\vidstabtransform.bat"

if not exist "%VIDSTABDETECT_MODULE%" (
    echo.
    echo [ERROR] Не найден модуль:
    echo         %VIDSTABDETECT_MODULE%
    echo.
    pause
    exit /b 1
)

if not exist "%VIDSTABTRANSFORM_MODULE%" (
    echo.
    echo [ERROR] Не найден модуль:
    echo         %VIDSTABTRANSFORM_MODULE%
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                     VidStab Auto
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Будут выполнены два этапа:
echo   1. Анализ движения камеры (vidstabdetect)
echo   2. Применение стабилизации (vidstabtransform)
echo.
echo ============================================================
echo.
echo  1. Запустить автоматическую стабилизацию
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto RUN_AUTO
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:RUN_AUTO
cls

echo ============================================================
echo                  Этап 1 из 2
echo                VidStab Detect
echo ============================================================
echo.

call "%VIDSTABDETECT_MODULE%"
if errorlevel 1 (
    echo.
    echo [ERROR] VidStab Detect завершился с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)

cls
echo ============================================================
echo                  Этап 2 из 2
echo               VidStab Transform
echo ============================================================
echo.

call "%VIDSTABTRANSFORM_MODULE%"
if errorlevel 1 (
    echo.
    echo [ERROR] VidStab Transform завершился с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                 Стабилизация завершена
echo ============================================================
echo.
pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0