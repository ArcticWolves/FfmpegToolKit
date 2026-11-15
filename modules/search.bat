@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\search.bat
rem Поиск по энкодерам, декодерам, фильтрам и форматам сборки,
rem а также подробная справка по конкретному имени.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Поиск кодеков и фильтров"
echo   1. Найти по слову (h264, blur, audio, png...)
echo   2. Справка по энкодеру (все параметры), например libopus
echo   3. Справка по фильтру, например drawtext
echo   4. Справка по формату (муксеру), например mp4
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if "%CHOICE%"=="1" goto FIND
if "%CHOICE%"=="2" (set "KIND=encoder" & goto HELP)
if "%CHOICE%"=="3" (set "KIND=filter" & goto HELP)
if "%CHOICE%"=="4" (set "KIND=muxer" & goto HELP)
if "%CHOICE%"=="0" goto EXIT_MODULE
call "%LIB%" :InvalidChoice
goto MAIN_MENU

:FIND
call "%LIB%" :Ask QUERY "Строка поиска" ""
call "%LIB%" :Sanitize QUERY
if not defined QUERY goto MAIN_MENU
cls
for %%L in (encoders decoders filters formats) do (
    echo.
    echo ===== %%L =====
    "%FFMPEG%" -hide_banner -%%L 2>nul | findstr /i /c:"%QUERY%"
)
echo.
pause
goto MAIN_MENU

:HELP
call "%LIB%" :Ask NAME "Имя (%KIND%)" ""
call "%LIB%" :Sanitize NAME
if not defined NAME goto MAIN_MENU
cls
"%FFMPEG%" -hide_banner -h %KIND%=%NAME% | more
pause
goto MAIN_MENU

:EXIT_MODULE
endlocal
exit /b 0
