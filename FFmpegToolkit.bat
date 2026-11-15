@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title FFmpeg ToolKit

rem ============================================================
rem FFmpegToolkit.bat
rem
rem Главная точка входа FFmpeg ToolKit.
rem   1. Загружает конфигурацию (config.bat).
rem   2. Показывает главное меню.
rem   3. Вызывает модули из папки modules.
rem
rem Архитектура:
rem   FFmpegToolkit.bat   точка входа
rem   config.bat          пути + определение возможностей сборки
rem   lib\common.bat      общие подпрограммы (ввод, запуск ffmpeg, журнал)
rem   lib\transcode.bat   общий движок перекодирования (convert + edit)
rem   modules\*.bat       разделы меню (контроллеры)
rem   modules\convert\    профили форматов (+ движки _image, _anim)
rem   modules\edit\       операции редактирования
rem   modules\tools\      утилиты
rem   modules\codecs\     модули кодеков (по одному на энкодер)
rem   selectors\          диалоги выбора (файл, кодек, LUT...)
rem ============================================================

call "%~dp0config.bat"
if errorlevel 1 exit /b 1
if not defined CONFIG_LOADED (
    echo [ERROR] config.bat не был загружен.
    pause
    exit /b 1
)

:MAIN_MENU
call "%LIB%" :Header "FFmpeg ToolKit"
echo   FFmpeg  : %FFMPEG_VERSION%  [%FFMPEG_LICENSE%]
echo   Папка   : %ROOT%
call :ShowBestEncoders
echo.
echo  1. Конвертация
echo  2. Редактирование
echo  3. Извлечение (аудио, кадры, субтитры...)
echo  4. Инструменты (превью, запись экрана, ремукс...)
echo  5. Пакетная обработка папки input
echo.
echo  6. Анализ файла       (FFprobe)
echo  7. Проигрыватель      (FFplay)
echo  8. Информация о сборке
echo  9. Поиск кодеков и фильтров
echo.
echo  R. Пересканировать возможности сборки
echo  0. Выход
echo.
call "%LIB%" :AskChoice "Выберите раздел"

if "%CHOICE%"=="1" call :RunModule "convert.bat"  & goto MAIN_MENU
if "%CHOICE%"=="2" call :RunModule "edit.bat"     & goto MAIN_MENU
if "%CHOICE%"=="3" call :RunModule "extract.bat"  & goto MAIN_MENU
if "%CHOICE%"=="4" call :RunModule "tools.bat"    & goto MAIN_MENU
if "%CHOICE%"=="5" call :RunModule "batch.bat"    & goto MAIN_MENU
if "%CHOICE%"=="6" call :RunModule "ffprobe.bat"  & goto MAIN_MENU
if "%CHOICE%"=="7" goto MENU_FFPLAY
if "%CHOICE%"=="8" call :RunModule "info.bat"     & goto MAIN_MENU
if "%CHOICE%"=="9" call :RunModule "search.bat"   & goto MAIN_MENU
if /i "%CHOICE%"=="R" goto RESCAN
if "%CHOICE%"=="0" goto EXIT_APP
call "%LIB%" :InvalidChoice
goto MAIN_MENU


:MENU_FFPLAY
if not "%HAS_FFPLAY%"=="1" (
    echo.
    echo [ERROR] ffplay.exe отсутствует в source\bin.
    echo.
    pause
    goto MAIN_MENU
)
call :RunModule "ffplay.bat"
goto MAIN_MENU


:RESCAN
if exist "%CAPS_DIR%\stamp.txt" del /q "%CAPS_DIR%\stamp.txt"
call "%~dp0config.bat"
goto MAIN_MENU


rem ============================================================
rem Запуск модуля в изолированном окружении: переменные модуля
rem не попадают в главное меню.
rem ============================================================
:RunModule
if not exist "%MODULES_DIR%\%~1" (
    echo.
    echo [ERROR] Не найден модуль: %MODULES_DIR%\%~1
    echo.
    pause
    exit /b 1
)
setlocal
call "%MODULES_DIR%\%~1"
endlocal
exit /b 0


rem ============================================================
rem Краткая сводка: лучший доступный энкодер H.264 / HEVC / AV1
rem ============================================================
:ShowBestEncoders
call "%LIB%" :PickBest _b264 "libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
call "%LIB%" :PickBest _b265 "libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar"
call "%LIB%" :PickBest _bav1 "libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e"
if not defined _b264 set "_b264=-"
if not defined _b265 set "_b265=-"
if not defined _bav1 set "_bav1=-"
echo   H.264: %_b264%   HEVC: %_b265%   AV1: %_bav1%
if "%HAS_VIDSTAB%"=="1" (echo   VidStab: да) else (echo   VidStab: нет ^(нужна GPL-сборка^))
set "_b264=" & set "_b265=" & set "_bav1="
exit /b 0


:EXIT_APP
cls
echo Спасибо за использование FFmpeg ToolKit.
endlocal
exit /b 0
