@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem selectors\select_output_file.bat
rem
rem Формирует путь выходного файла в папке output.
rem
rem Вход:
rem   INPUT_FILE     входной файл (для имени по умолчанию)
rem   OUTPUT_EXT     расширение без точки (обязательно)
rem   OUTPUT_SUFFIX  суффикс имени (по умолчанию "out")
rem   OUTPUT_BASE    базовое имя вместо имени входного файла (необязательно)
rem
rem Результат: OUTPUT_FILE (errorlevel 0) или отмена (errorlevel 1).
rem Перезапись входного файла запрещена.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)
if not defined OUTPUT_EXT (echo [ERROR] OUTPUT_EXT не задан. & pause & exit /b 1)
if not defined OUTPUT_SUFFIX set "OUTPUT_SUFFIX=out"

set "BASE=output"
if defined INPUT_FILE for %%F in ("%INPUT_FILE%") do set "BASE=%%~nF"
if defined OUTPUT_BASE set "BASE=%OUTPUT_BASE%"

:MAIN_MENU
call "%LIB%" :Header "Выходной файл (.%OUTPUT_EXT%)"
echo  1. !BASE!_%OUTPUT_SUFFIX%.%OUTPUT_EXT%   [Enter]
echo  2. !BASE!.%OUTPUT_EXT%
echo  3. Ввести имя вручную
echo  0. Отмена
echo.
call "%LIB%" :AskChoice "Выберите вариант"
if not defined CHOICE set "CHOICE=1"

if "%CHOICE%"=="1" (set "NAME=%BASE%_%OUTPUT_SUFFIX%" & goto BUILD)
if "%CHOICE%"=="2" (set "NAME=%BASE%" & goto BUILD)
if "%CHOICE%"=="3" goto CUSTOM
if "%CHOICE%"=="0" goto CANCEL
call "%LIB%" :InvalidChoice
goto MAIN_MENU

:CUSTOM
call "%LIB%" :Ask NAME "Имя файла без расширения" ""
call "%LIB%" :Sanitize NAME
if not defined NAME goto MAIN_MENU
set "NAME=!NAME:\=_!"
set "NAME=!NAME:/=_!"
set "NAME=!NAME::=_!"
set "NAME=!NAME:?=_!"
goto BUILD

:BUILD
set "RESULT=%OUTPUT_DIR%\%NAME%.%OUTPUT_EXT%"

if defined INPUT_FILE if /i "%RESULT%"=="%INPUT_FILE%" (
    echo.
    echo [ERROR] Выходной файл совпадает с входным. Выберите другое имя.
    pause
    goto MAIN_MENU
)

if exist "%RESULT%" (
    echo.
    echo [WARN] Файл уже существует:
    echo        !RESULT!
    call "%LIB%" :AskYN "Перезаписать?" N
    if errorlevel 1 goto MAIN_MENU
)
goto SUCCESS

:CANCEL
endlocal & set "OUTPUT_FILE="
exit /b 1

:SUCCESS
endlocal & set "OUTPUT_FILE=%RESULT%"
exit /b 0
