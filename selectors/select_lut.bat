@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem lib\select_lut.bat
rem
rem Универсальный селектор LUT-файлов.
rem
rem Назначение:
rem   1. Сканирует каталог %LUTS_DIR%.
rem   2. Ищет поддерживаемые LUT-файлы.
rem   3. Показывает список найденных файлов.
rem   4. Позволяет выбрать LUT по номеру.
rem   5. Если LUT не найдено, предлагает ввести путь вручную.
rem   6. Возвращает:
rem        SELECTED_LUT - полный путь к выбранному LUT-файлу.
rem
rem Поддерживаемые расширения:
rem   .cube
rem   .3dl
rem   .dat
rem   .m3d
rem   .csp
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

set "SELECTED_LUT="
set "LUT_COUNT=0"

rem ------------------------------------------------------------
rem Поиск LUT-файлов
rem ------------------------------------------------------------
for %%F in (
    "%LUTS_DIR%\*.cube"
    "%LUTS_DIR%\*.3dl"
    "%LUTS_DIR%\*.dat"
    "%LUTS_DIR%\*.m3d"
    "%LUTS_DIR%\*.csp"
) do (
    if exist "%%~fF" (
        set /a LUT_COUNT+=1
        set "LUT[!LUT_COUNT!]=%%~fF"
        set "LUT_NAME[!LUT_COUNT!]=%%~nxF"
    )
)

rem ------------------------------------------------------------
rem Если LUT-файлы найдены
rem ------------------------------------------------------------
if %LUT_COUNT% GTR 0 goto SHOW_MENU

rem ------------------------------------------------------------
rem LUT-файлы не найдены
rem ------------------------------------------------------------
echo.
echo [INFO] В каталоге LUT не найдено файлов.
echo [INFO] Каталог:
echo        %LUTS_DIR%
echo.
goto MANUAL_INPUT


:SHOW_MENU
cls
echo ============================================================
echo                        Выбор LUT
echo ============================================================
echo.
echo Каталог:
echo %LUTS_DIR%
echo.

for /L %%I in (1,1,%LUT_COUNT%) do (
    echo  %%I. !LUT_NAME[%%I]!
)

echo.
echo  M. Ввести путь вручную
echo  0. Отмена
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите LUT: "

if /I "%CHOICE%"=="M" goto MANUAL_INPUT
if "%CHOICE%"=="0" goto CANCEL

rem Проверка, что введено число
for /f "delims=0123456789" %%A in ("%CHOICE%") do goto INVALID

if %CHOICE% GEQ 1 if %CHOICE% LEQ %LUT_COUNT% (
    set "SELECTED_LUT=!LUT[%CHOICE%]!"
    goto SUCCESS
)

goto INVALID


:MANUAL_INPUT
echo.
set /p "SELECTED_LUT=Введите полный путь к LUT-файлу: "

if not defined SELECTED_LUT goto CANCEL

if not exist "%SELECTED_LUT%" (
    echo.
    echo [ERROR] Файл не найден:
    echo         %SELECTED_LUT%
    echo.
    pause
    goto MANUAL_INPUT
)

goto SUCCESS


:INVALID
echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto SHOW_MENU


:CANCEL
endlocal & set "SELECTED_LUT="
exit /b 1


:SUCCESS
endlocal & set "SELECTED_LUT=%SELECTED_LUT%"
exit /b 0