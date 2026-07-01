@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem ============================================================
rem modules\search.bat
rem
rem Search codecs, encoders, decoders and filters in current FFmpeg build.
rem ============================================================

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
echo                         Поиск
echo ============================================================
echo.
echo Поиск выполняется по codec / encoder / decoder / filter.
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "QUERY="
set /p "QUERY=Введите строку поиска: "

if not defined QUERY goto EXIT_MODULE
if "%QUERY%"=="0" goto EXIT_MODULE

echo.
echo ===== Codecs =====
"%FFMPEG%" -hide_banner -codecs | findstr /i /c:"%QUERY%"

echo.
echo ===== Encoders =====
"%FFMPEG%" -hide_banner -encoders | findstr /i /c:"%QUERY%"

echo.
echo ===== Decoders =====
"%FFMPEG%" -hide_banner -decoders | findstr /i /c:"%QUERY%"

echo.
echo ===== Filters =====
"%FFMPEG%" -hide_banner -filters | findstr /i /c:"%QUERY%"

echo.
pause
goto MAIN_MENU

:EXIT_MODULE
endlocal
exit /b 0
