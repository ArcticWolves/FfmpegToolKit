@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\stabilization.bat
rem
rem Раздел "Стабилизация видео".
rem
rem Назначение:
rem   Отображает меню доступных методов стабилизации и
rem   передаёт управление соответствующим подмодулям.
rem
rem Подмодули:
rem   modules\edit\stabilizators\deshake.bat
rem   modules\edit\stabilizators\vidstabdetect.bat
rem   modules\edit\stabilizators\vidstabtransform.bat
rem
rem Архитектурная роль:
rem   Controller
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

:MAIN_MENU
cls

echo ============================================================
echo                    Стабилизация видео
echo ============================================================
echo.
echo  1. Deshake (встроенный фильтр FFmpeg)
echo  2. VidStab Detect
echo  3. VidStab Transform
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите метод стабилизации: "

if "%CHOICE%"=="1" goto MENU_DESHAKE
if "%CHOICE%"=="2" goto MENU_VIDSTABDETECT
if "%CHOICE%"=="3" goto MENU_VIDSTABTRANSFORM
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Deshake
rem ============================================================
:MENU_DESHAKE
call :RunModule "edit\stabilizators\deshake.bat"
goto MAIN_MENU


rem ============================================================
rem VidStab Detect
rem ============================================================
:MENU_VIDSTABDETECT
call :RunModule "edit\stabilizators\vidstabdetect.bat"
goto MAIN_MENU


rem ============================================================
rem VidStab Transform
rem ============================================================
:MENU_VIDSTABTRANSFORM
call :RunModule "edit\stabilizators\vidstabtransform.bat"
goto MAIN_MENU


rem ============================================================
rem Универсальный запуск подмодуля
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