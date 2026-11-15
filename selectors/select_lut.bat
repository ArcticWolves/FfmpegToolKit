@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem selectors\select_lut.bat
rem Выбор LUT-файла из папки luts или вручную.
rem Поддерживаются форматы фильтра lut3d: .cube .3dl .dat .m3d .csp
rem Результат: SELECTED_LUT (errorlevel 0) или отмена (errorlevel 1).
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:LIST
set "LUT_COUNT=0"
for /f "delims=" %%F in ('dir /b /a-d /on "%LUTS_DIR%\*.cube" "%LUTS_DIR%\*.3dl" "%LUTS_DIR%\*.dat" "%LUTS_DIR%\*.m3d" "%LUTS_DIR%\*.csp" 2^>nul') do (
    call :AddLut "%LUTS_DIR%\%%F"
)

call "%LIB%" :Header "Выбор LUT"
echo Папка: %LUTS_DIR%
echo.
if "%LUT_COUNT%"=="0" echo   [LUT-файлов нет - положите .cube в папку luts]
for /L %%I in (1,1,%LUT_COUNT%) do call :ShowLut %%I
echo.
echo  M. Указать путь вручную
echo  0. Отмена
echo.
call "%LIB%" :AskChoice "Выберите LUT"
if not defined CHOICE goto LIST
if /i "%CHOICE%"=="M" goto MANUAL
if "%CHOICE%"=="0" goto CANCEL
call "%LIB%" :IsInt "%CHOICE%"
if errorlevel 1 goto INVALID
if %CHOICE% LSS 1 goto INVALID
if %CHOICE% GTR %LUT_COUNT% goto INVALID
call set "SELECTED=%%LUT_%CHOICE%%%"
goto SUCCESS

:MANUAL
call "%LIB%" :AskFile SELECTED "Полный путь к LUT-файлу"
if errorlevel 1 goto LIST
goto SUCCESS

:INVALID
call "%LIB%" :InvalidChoice
goto LIST

:AddLut
if not exist "%~1" exit /b 0
set /a LUT_COUNT+=1
set "LUT_%LUT_COUNT%=%~1"
set "LUT_NAME_%LUT_COUNT%=%~nx1"
exit /b 0

:ShowLut
call set "_n=%%LUT_NAME_%1%%"
set "_i=   %1"
echo  %_i:~-3%. %_n%
exit /b 0

:CANCEL
endlocal & set "SELECTED_LUT="
exit /b 1

:SUCCESS
endlocal & set "SELECTED_LUT=%SELECTED%"
exit /b 0
