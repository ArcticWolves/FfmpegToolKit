@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_input_file.bat
rem
rem Универсальный выбор входного файла из каталога input.
rem Возвращает:
rem   INPUT_FILE
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

set "SELECTED_INPUT_FILE="
set "FILE_COUNT=0"

for /f "delims=" %%F in ('dir /b /a-d "%INPUT_DIR%" 2^>nul') do (
    set /a FILE_COUNT+=1
    set "FILE_!FILE_COUNT!=%INPUT_DIR%\%%F"
    set "FILE_NAME_!FILE_COUNT!=%%F"
)

if "!FILE_COUNT!"=="0" (
    echo.
    echo [ERROR] В папке input нет файлов.
    echo        %INPUT_DIR%
    echo.
    pause
    exit /b 1
)

if "!FILE_COUNT!"=="1" (
    set "SELECTED_INPUT_FILE=!FILE_1!"
    goto SUCCESS
)

cls
echo ============================================================
echo                    Выбор входного файла
echo ============================================================
echo.
echo Каталог:
echo %INPUT_DIR%
echo.

for /L %%I in (1,1,!FILE_COUNT!) do (
    echo  %%I. !FILE_NAME_%%I!
)

echo.
echo  0. Отмена
echo.
echo ============================================================
echo.

set "FILE_INDEX="
set /p "FILE_INDEX=Выберите номер файла: "

if "%FILE_INDEX%"=="0" goto CANCEL
if not defined FILE_INDEX goto CANCEL

call set "SELECTED_INPUT_FILE=%%FILE_%FILE_INDEX%%%"

if not defined SELECTED_INPUT_FILE (
    echo.
    echo [ERROR] Некорректный выбор.
    echo.
    pause
    exit /b 1
)

goto SUCCESS

:CANCEL
endlocal & set "INPUT_FILE="
exit /b 1

:SUCCESS
endlocal & set "INPUT_FILE=%SELECTED_INPUT_FILE%"
exit /b 0
