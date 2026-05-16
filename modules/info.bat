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
rem   текущей сборке FFmpeg и позволяет сохранить вывод
rem   в каталог logs.
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

if "%CHOICE%"=="1"  goto SHOW_VERSION
if "%CHOICE%"=="2"  goto SHOW_BUILDCONF
if "%CHOICE%"=="3"  goto SHOW_CODECS
if "%CHOICE%"=="4"  goto SHOW_ENCODERS
if "%CHOICE%"=="5"  goto SHOW_DECODERS
if "%CHOICE%"=="6"  goto SHOW_FILTERS
if "%CHOICE%"=="7"  goto SHOW_HWACCELS
if "%CHOICE%"=="8"  goto SHOW_FORMATS
if "%CHOICE%"=="9"  goto SHOW_PROTOCOLS
if "%CHOICE%"=="10" goto SHOW_DEVICES
if "%CHOICE%"=="11" goto SHOW_LICENSE
if "%CHOICE%"=="0"  goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Подпрограмма запуска команды FFmpeg
rem
rem Аргументы:
rem   %~1 - аргумент командной строки FFmpeg
rem   %~2 - базовое имя лог-файла
rem ============================================================
:RunFFmpegCommand
cls

echo ============================================================
echo Выполнение: "%FFMPEG%" %~1
echo ============================================================
echo.

set "SAVE_LOG="
set /p "SAVE_LOG=Сохранить вывод в logs? (Y/N): "

if /i "%SAVE_LOG%"=="Y" (
    rem Формирование временной метки
    for /f %%I in ('
        powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"
    ') do (
        set "TIMESTAMP=%%I"
    )

    rem Имя лог-файла
    set "LOG_BASENAME=%~2"
    if not defined LOG_BASENAME set "LOG_BASENAME=ffmpeg_info"

    set "LOG_FILE=%LOG_DIR%\%LOG_BASENAME%_%TIMESTAMP%.txt"

    echo.
    echo Сохранение в:
    echo %LOG_FILE%
    echo.

    "%FFMPEG%" %~1 > "%LOG_FILE%" 2>&1

    echo.
    echo ============================================================
    echo                        Лог сохранен
    echo ============================================================
    echo.
    echo %LOG_FILE%
    echo.
) else (
    "%FFMPEG%" %~1
)

echo.
pause
exit /b 0


:SHOW_VERSION
call :RunFFmpegCommand -version version
goto MAIN_MENU

:SHOW_BUILDCONF
call :RunFFmpegCommand -buildconf buildconf
goto MAIN_MENU

:SHOW_CODECS
call :RunFFmpegCommand -codecs codecs
goto MAIN_MENU

:SHOW_ENCODERS
call :RunFFmpegCommand -encoders encoders
goto MAIN_MENU

:SHOW_DECODERS
call :RunFFmpegCommand -decoders decoders
goto MAIN_MENU

:SHOW_FILTERS
call :RunFFmpegCommand -filters filters
goto MAIN_MENU

:SHOW_HWACCELS
call :RunFFmpegCommand -hwaccels hwaccels
goto MAIN_MENU

:SHOW_FORMATS
call :RunFFmpegCommand -formats formats
goto MAIN_MENU

:SHOW_PROTOCOLS
call :RunFFmpegCommand -protocols protocols
goto MAIN_MENU

:SHOW_DEVICES
call :RunFFmpegCommand -devices devices
goto MAIN_MENU

:SHOW_LICENSE
call :RunFFmpegCommand -L license
goto MAIN_MENU


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0