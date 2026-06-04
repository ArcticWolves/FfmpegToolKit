@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\filters\color_correction.bat
::
:: Раздел цветокоррекции.
::
:: Доступные фильтры:
::   1. eq  - яркость, контраст, насыщенность, гамма
::   2. hue - оттенок и насыщенность
::
:: Архитектурная роль:
::   Controller для фильтров цветокоррекции.
:: ============================================================

:: ------------------------------------------------------------
:: Проверка загрузки конфигурации
:: ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                     Цветокоррекция
echo ============================================================
echo.
echo  1. Equalizer (eq) - яркость, контраст, насыщенность, гамма
echo  2. Hue (hue)      - оттенок и насыщенность
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите фильтр: "

if "%CHOICE%"=="1" goto MENU_EQUALIZER
if "%CHOICE%"=="2" goto MENU_HUE
if "%CHOICE%"=="0" goto EXIT_MODULE

if not "%CHOICE%"=="1" if not "%CHOICE%"=="2" (
    echo.
    echo [ERROR] Некорректный выбор.
    echo.
    pause
)

goto MAIN_MENU


:MENU_EQUALIZER
call :RunModule "edit\filters\color_equalizer.bat"
goto MAIN_MENU


:MENU_HUE
call :RunModule "edit\filters\color_hue.bat"
goto MAIN_MENU


:: ============================================================
:: Универсальный запуск подмодуля
::
:: Аргумент:
::   %~1 - относительный путь внутри %MODULES_DIR%
:: ============================================================
:RunModule
set "MODULE_PATH=%MODULES_DIR%\%~1"

if not exist "%MODULE_PATH%" (
    echo.
    echo [ERROR] Не найден модуль:
    echo         %MODULE_PATH%
    echo.
    pause
    exit /b 1
)

call "%MODULE_PATH%"
exit /b 0


:: ============================================================
:: Выход
:: ============================================================
:EXIT_MODULE
endlocal
exit /b 0
