@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\info.bat
rem
rem Информационный модуль FFmpeg ToolKit.
rem
rem Назначение:
rem   Предоставляет доступ к диагностической информации о
rem   текущей сборке FFmpeg.
rem
rem Архитектурная роль:
rem   Controller для информационных и диагностических команд.
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg.html
rem ============================================================

rem ------------------------------------------------------------
rem Проверка конфигурации
rem ------------------------------------------------------------
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
echo                     Информация
echo ============================================================
echo.
echo Версия FFmpeg:
echo %FFMPEG_VERSION%
echo.
echo ============================================================
echo.
echo  1. Версия FFmpeg
echo  2. Build Configuration
echo  3. Кодеки
echo  4. Энкодеры
echo  5. Декодеры
echo  6. Фильтры
echo  7. Аппаратные ускорители
echo  8. Форматы
echo  9. Протоколы
echo 10. Устройства
echo 11. Лицензия
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите пункт: "

if "%CHOICE%"=="1" goto SHOW_VERSION
if "%CHOICE%"=="2" goto SHOW_BUILDCONF
if "%CHOICE%"=="3" goto SHOW_CODECS
if "%CHOICE%"=="4" goto SHOW_ENCODERS
if "%CHOICE%"=="5" goto SHOW_DECODERS
if "%CHOICE%"=="6" goto SHOW_FILTERS
if "%CHOICE%"=="7" goto SHOW_HWACCELS
if "%CHOICE%"=="8" goto SHOW_FORMATS
if "%CHOICE%"=="9" goto SHOW_PROTOCOLS
if "%CHOICE%"=="10" goto SHOW_DEVICES
if "%CHOICE%"=="11" goto SHOW_LICENSE
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Подпрограмма запуска команды FFmpeg
rem Аргумент:
rem   %~1 - аргумент командной строки FFmpeg
rem ============================================================
:RunFFmpegCommand
cls

echo ============================================================
echo Выполнение: "%FFMPEG%" %~1
echo ============================================================
echo.

"%FFMPEG%" %~1

echo.
pause
exit /b 0


:SHOW_VERSION
call :RunFFmpegCommand -version
goto MAIN_MENU

:SHOW_BUILDCONF
call :RunFFmpegCommand -buildconf
goto MAIN_MENU

:SHOW_CODECS
call :RunFFmpegCommand -codecs
goto MAIN_MENU

:SHOW_ENCODERS
call :RunFFmpegCommand -encoders
goto MAIN_MENU

:SHOW_DECODERS
call :RunFFmpegCommand -decoders
goto MAIN_MENU

:SHOW_FILTERS
call :RunFFmpegCommand -filters
goto MAIN_MENU

:SHOW_HWACCELS
call :RunFFmpegCommand -hwaccels
goto MAIN_MENU

:SHOW_FORMATS
call :RunFFmpegCommand -formats
goto MAIN_MENU

:SHOW_PROTOCOLS
call :RunFFmpegCommand -protocols
goto MAIN_MENU

:SHOW_DEVICES
call :RunFFmpegCommand -devices
goto MAIN_MENU

:SHOW_LICENSE
call :RunFFmpegCommand -L
goto MAIN_MENU


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0