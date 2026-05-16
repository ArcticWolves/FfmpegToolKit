@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\stabilization.bat
::
:: Раздел "Стабилизация видео".
::
:: Поддерживаемые методы:
::   1. deshake
::   2. vidstab (автоматический двухпроходный режим)
::   3. vidstabdetect   (служебный)
::   4. vidstabtransform (служебный)
:: ============================================================

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
echo  1. Deshake
echo  2. VidStab (Автоматическая стабилизация)
echo.
echo  3. VidStab Detect    [Служебный режим]
echo  4. VidStab Transform [Служебный режим]
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите метод стабилизации: "

if "%CHOICE%"=="1" goto MENU_DESHAKE
if "%CHOICE%"=="2" goto MENU_VIDSTAB
if "%CHOICE%"=="3" goto MENU_VIDSTABDETECT
if "%CHOICE%"=="4" goto MENU_VIDSTABTRANSFORM
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:MENU_DESHAKE
call :RunModule "edit\stabilizators\deshake.bat"
goto MAIN_MENU


:MENU_VIDSTAB
call :RunModule "edit\stabilizators\vidstab.bat"
goto MAIN_MENU


:MENU_VIDSTABDETECT
call :RunModule "edit\stabilizators\vidstabdetect.bat"
goto MAIN_MENU


:MENU_VIDSTABTRANSFORM
call :RunModule "edit\stabilizators\vidstabtransform.bat"
goto MAIN_MENU


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


:EXIT_MODULE
endlocal
exit /b 0