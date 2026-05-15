@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit.bat
rem
rem Раздел "Редактирование".
rem
rem Архитектурная роль:
rem   Controller.
rem
rem Текущая структура:
rem   modules\
rem       edit.bat
rem       edit\
rem           trim.bat
rem           filters\
rem               color_correction.bat
rem               color_equalizer.bat
rem               color_hue.bat
rem ============================================================

rem ------------------------------------------------------------
rem Проверка загрузки конфигурации
rem ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolkit.bat.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                      Редактирование
echo ============================================================
echo.
echo  1. Обрезка (Trim)
echo  2. Цветокоррекция
echo  3. Стабилизация
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" call :RunModule "edit\trim.bat"
if "%CHOICE%"=="2" call :RunModule "edit\color_correction.bat"
if "%CHOICE%"=="3" call :RunModule "edit\stabilization.bat"
if "%CHOICE%"=="0" goto EXIT_MODULE

if not "%CHOICE%"=="1" if not "%CHOICE%"=="2" (
    echo.
    echo [ERROR] Некорректный выбор.
    echo.
    pause
)

goto MAIN_MENU


rem ============================================================
rem Универсальный запуск модуля
rem
rem Аргумент:
rem   %~1 - относительный путь внутри %MODULES_DIR%
rem ============================================================
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


rem ============================================================
rem Выход из раздела
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0