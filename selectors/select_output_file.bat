@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_output_file.bat
rem
rem Required:
rem   INPUT_FILE
rem   OUTPUT_EXT
rem Optional:
rem   OUTPUT_SUFFIX
rem Returns:
rem   OUTPUT_FILE
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo.
    pause
    exit /b 1
)

if not defined INPUT_FILE exit /b 1
if not defined OUTPUT_EXT exit /b 1
if not defined OUTPUT_SUFFIX set "OUTPUT_SUFFIX=converted"

for %%F in ("%INPUT_FILE%") do set "INPUT_NAME=%%~nF"

:MAIN_MENU
cls
echo ============================================================
echo                   Выходной файл
echo ============================================================
echo.
echo  1. Использовать имя входного файла
echo  2. Использовать имя входного файла с суффиксом
echo  3. Ввести имя вручную
echo.
echo  0. Отмена
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите вариант: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" set "OUTPUT_NAME=%INPUT_NAME%" & goto BUILD_PATH
if "%CHOICE%"=="2" set "OUTPUT_NAME=%INPUT_NAME%_%OUTPUT_SUFFIX%" & goto BUILD_PATH
if "%CHOICE%"=="3" goto CUSTOM_NAME
if "%CHOICE%"=="0" goto CANCEL

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU

:CUSTOM_NAME
echo.
set "OUTPUT_NAME="
set /p "OUTPUT_NAME=Имя выходного файла без расширения: "
if not defined OUTPUT_NAME goto MAIN_MENU
goto BUILD_PATH

:BUILD_PATH
set "SELECTED_OUTPUT_FILE=%OUTPUT_DIR%\%OUTPUT_NAME%.%OUTPUT_EXT%"

if exist "%SELECTED_OUTPUT_FILE%" (
    echo.
    echo [WARN] Файл уже существует:
    echo        %SELECTED_OUTPUT_FILE%
    echo.
    choice /c YNC /m "Перезаписать? Y=да, N=другое имя, C=отмена"
    if errorlevel 3 goto CANCEL
    if errorlevel 2 goto MAIN_MENU
)

goto SUCCESS

:CANCEL
endlocal & set "OUTPUT_FILE="
exit /b 1

:SUCCESS
endlocal & set "OUTPUT_FILE=%SELECTED_OUTPUT_FILE%"
exit /b 0
