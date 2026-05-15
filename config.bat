@echo off
setlocal

:: ============================================================================
:: CONFIG.BAT
:: Центральная конфигурация проекта FFmpegToolKit
:: ============================================================================



rem ----------------------------------------------------------------------------
rem Корневой каталог проекта (без завершающего обратного слэша)
rem ----------------------------------------------------------------------------
for %%I in ("%~dp0.") do set "ROOT=%%~fI"


:: ----------------------------------------------------------------------------
:: Пути к исполняемым файлам FFmpeg
:: ----------------------------------------------------------------------------
set "FFMPEG=%ROOT%\source\bin\ffmpeg.exe"
set "FFPROBE=%ROOT%\source\bin\ffprobe.exe"
set "FFPLAY=%ROOT%\source\bin\ffplay.exe"


:: ----------------------------------------------------------------------------
:: Рабочие каталоги
:: ----------------------------------------------------------------------------
set "INPUT_DIR=%ROOT%\input"
set "OUTPUT_DIR=%ROOT%\output"
set "TEMP_DIR=%ROOT%\temp"
set "LOG_DIR=%ROOT%\logs"
set "MODULES_DIR=%ROOT%\modules"
set "PRESETS_DIR=%ROOT%\presets"


:: ----------------------------------------------------------------------------
:: Системные настройки FFmpeg
:: ----------------------------------------------------------------------------
set "FFMPEG_GLOBAL_OPTIONS=-hide_banner -y"
set "FFPROBE_GLOBAL_OPTIONS=-v error"
set "FFPLAY_GLOBAL_OPTIONS=-hide_banner -loglevel error"


rem ----------------------------------------------------------------------------
rem Создание необходимых каталогов
rem ----------------------------------------------------------------------------
for %%D in (
    "%INPUT_DIR%"
    "%OUTPUT_DIR%"
    "%TEMP_DIR%"
    "%LOG_DIR%"
    "%PRESETS_DIR%"
) do (if not exist "%%~D" mkdir "%%~D")




rem ----------------------------------------------------------------------------
rem Проверка наличия обязательных файлов
rem ----------------------------------------------------------------------------
call :CheckFile "%FFMPEG%"  "ffmpeg.exe"  || exit /b 1
call :CheckFile "%FFPROBE%" "ffprobe.exe" || exit /b 1
call :CheckFile "%FFPLAY%"  "ffplay.exe"  || exit /b 1

rem ----------------------------------------------------------------------------
rem Проверка версии FFmpeg (дополнительная диагностика)
rem ----------------------------------------------------------------------------
for /f "tokens=3" %%V in ('"%FFMPEG%" -version 2^>nul ^| findstr /b "ffmpeg version"') do (
    set "FFMPEG_VERSION=%%V"
    goto :VersionDetected
)
set "FFMPEG_VERSION=unknown"

:VersionDetected

rem ----------------------------------------------------------------------------
rem Экспорт успешного состояния конфигурации
rem ----------------------------------------------------------------------------
set "CONFIG_LOADED=1"

endlocal & (
    set "ROOT=%ROOT%"
    set "FFMPEG=%FFMPEG%"
    set "FFPROBE=%FFPROBE%"
    set "FFPLAY=%FFPLAY%"

    set "INPUT_DIR=%INPUT_DIR%"
    set "OUTPUT_DIR=%OUTPUT_DIR%"
    set "TEMP_DIR=%TEMP_DIR%"
    set "LOG_DIR=%LOG_DIR%"
    set "MODULES_DIR=%MODULES_DIR%"
    set "PRESETS_DIR=%PRESETS_DIR%"

    set "FFMPEG_GLOBAL_OPTIONS=%FFMPEG_GLOBAL_OPTIONS%"
    set "FFPROBE_GLOBAL_OPTIONS=%FFPROBE_GLOBAL_OPTIONS%"
    set "FFPLAY_GLOBAL_OPTIONS=%FFPLAY_GLOBAL_OPTIONS%"

    set "HAS_FFPLAY=%HAS_FFPLAY%"
    set "FFMPEG_VERSION=%FFMPEG_VERSION%"
    set "CONFIG_LOADED=%CONFIG_LOADED%"
)

exit /b 0


rem ============================================================================
rem Проверка существования файла
rem ============================================================================
:CheckFile
if not exist "%~1" (
    echo.
    echo [ERROR] Не найден %~2
    echo [ERROR] Ожидаемый путь:
    echo         %~1
    echo.
    pause
    exit /b 1
)
exit /b 0
