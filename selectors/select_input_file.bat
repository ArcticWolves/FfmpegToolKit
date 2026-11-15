@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem selectors\select_input_file.bat
rem
rem Выбор входного файла из папки input или вручную.
rem
rem Вход (необязательно):
rem   INPUT_TITLE  заголовок экрана
rem   INPUT_KIND   all (по умолчанию) | any - показывать и не медиафайлы
rem
rem Результат (errorlevel 0):
rem   INPUT_FILE   полный путь
rem   INPUT_NAME   имя без расширения
rem   INPUT_EXT    расширение без точки (в нижнем регистре не приводится)
rem errorlevel 1 - отмена
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)
if not defined INPUT_TITLE set "INPUT_TITLE=Выбор входного файла"

:LIST
set "FILE_COUNT=0"
for /f "delims=" %%F in ('dir /b /a-d /on "%INPUT_DIR%" 2^>nul') do (
    set "_ok=1"
    if /i not "%INPUT_KIND%"=="any" (
        call "%LIB%" :IsMediaFile "%%F"
        if errorlevel 1 set "_ok="
    )
    if defined _ok (
        set /a FILE_COUNT+=1
        set "FILE_!FILE_COUNT!=%INPUT_DIR%\%%F"
        set "FILE_NAME_!FILE_COUNT!=%%F"
    )
)

call "%LIB%" :Header "%INPUT_TITLE%"
echo Папка: %INPUT_DIR%
echo.
if "%FILE_COUNT%"=="0" (
    echo   [папка input пуста - положите файлы туда или укажите путь]
) else (
    for /L %%I in (1,1,%FILE_COUNT%) do call :ShowFile %%I
)
echo.
echo  P. Указать путь вручную
echo  O. Открыть папку input
echo  U. Обновить список
echo  0. Отмена
echo.
if "%FILE_COUNT%"=="1" (
    call "%LIB%" :AskChoice "Выберите файл [Enter = 1]"
    if not defined CHOICE set "CHOICE=1"
) else (
    call "%LIB%" :AskChoice "Выберите файл"
)

if not defined CHOICE goto LIST
if "%CHOICE%"=="0" goto CANCEL
if /i "%CHOICE%"=="U" goto LIST
if /i "%CHOICE%"=="O" (start "" "%INPUT_DIR%" & goto LIST)
if /i "%CHOICE%"=="P" goto MANUAL

call "%LIB%" :IsInt "%CHOICE%"
if errorlevel 1 goto INVALID
if %CHOICE% LSS 1 goto INVALID
if %CHOICE% GTR %FILE_COUNT% goto INVALID
set "SELECTED=!FILE_%CHOICE%!"
goto SUCCESS

:MANUAL
call "%LIB%" :AskFile SELECTED "Полный путь к файлу"
if errorlevel 1 goto LIST
goto SUCCESS

:INVALID
call "%LIB%" :InvalidChoice
goto LIST

:ShowFile
call set "_n=%%FILE_NAME_%1%%"
echo  %1. !_n!
exit /b 0

:CANCEL
endlocal & set "INPUT_FILE="
exit /b 1

:SUCCESS
for %%F in ("%SELECTED%") do (
    set "S_NAME=%%~nF"
    set "S_EXT=%%~xF"
)
if defined S_EXT set "S_EXT=%S_EXT:~1%"
endlocal & (
    set "INPUT_FILE=%SELECTED%"
    set "INPUT_NAME=%S_NAME%"
    set "INPUT_EXT=%S_EXT%"
)
exit /b 0
