@echo off
setlocal EnableExtensions

rem ============================================================
rem presets\stabilizators\deshake_presset.bat
rem
rem Returns DESHAKE_FILTER for modules\edit\stabilizators\deshake.bat.
rem Argument:
rem   fast | standard | strong
rem ============================================================

set "PRESET=%~1"

if /I "%PRESET%"=="fast" goto FAST
if /I "%PRESET%"=="standard" goto STANDARD
if /I "%PRESET%"=="strong" goto STRONG

echo.
echo [ERROR] Неизвестный Deshake preset: %PRESET%
echo.
endlocal
exit /b 1

:FAST
set "FILTER=deshake=rx=8:ry=8:search=less:edge=mirror:blocksize=8"
goto SUCCESS

:STANDARD
set "FILTER=deshake=rx=16:ry=16:edge=mirror:blocksize=8"
goto SUCCESS

:STRONG
set "FILTER=deshake=rx=32:ry=32:search=exhaustive:edge=mirror:blocksize=8"
goto SUCCESS

:SUCCESS
endlocal & set "DESHAKE_FILTER=%FILTER%"
exit /b 0
