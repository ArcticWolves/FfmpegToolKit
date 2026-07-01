@echo off
setlocal EnableExtensions

:: ============================================================================
:: config.bat
:: Центральная конфигурация проекта FFmpeg ToolKit
::
:: Назначение:
::   - Определить корневой каталог проекта.
::   - Задать пути к ffmpeg.exe, ffprobe.exe и ffplay.exe.
::   - Создать рабочие каталоги.
::   - Проверить наличие обязательных компонентов.
::   - Определить версию FFmpeg.
::   - Экспортировать переменные в вызывающий скрипт.
:: ============================================================================


:: ----------------------------------------------------------------------------
:: Корневой каталог проекта (без завершающего "\")
:: ----------------------------------------------------------------------------
for %%I in ("%~dp0.") do set "ROOT=%%~fI"


:: ----------------------------------------------------------------------------
:: Пути к исполняемым файлам FFmpeg
:: ----------------------------------------------------------------------------
set "FFMPEG=%ROOT%\source\bin\ffmpeg.exe"
set "FFPROBE=%ROOT%\source\bin\ffprobe.exe"
set "FFPLAY=%ROOT%\source\bin\ffplay.exe"


:: ----------------------------------------------------------------------------
:: Рабочие каталоги проекта
:: ----------------------------------------------------------------------------
set "INPUT_DIR=%ROOT%\input"
set "OUTPUT_DIR=%ROOT%\output"
set "TEMP_DIR=%ROOT%\temp"
set "LOG_DIR=%TEMP_DIR%\logs"
set "MODULES_DIR=%ROOT%\modules"
set "CODECS_DIR=%MODULES_DIR%\codecs"
set "PRESETS_DIR=%ROOT%\presets"
set "LUTS_DIR=%ROOT%\luts"
set "SELECTORS_DIR=%ROOT%\selectors"
set "TRANSFORMS_DIR=%TEMP_DIR%\transforms"
set "PALETTES_DIR=%TEMP_DIR%\palettes"

:: ----------------------------------------------------------------------------
:: Глобальные параметры FFmpeg
:: ----------------------------------------------------------------------------
set "FFMPEG_GLOBAL_OPTIONS=-hide_banner -y"
set "FFPROBE_GLOBAL_OPTIONS=-v error"
set "FFPLAY_GLOBAL_OPTIONS=-hide_banner -loglevel error"


:: ----------------------------------------------------------------------------
:: Создание рабочих каталогов
:: ----------------------------------------------------------------------------
for %%D in (
    "%INPUT_DIR%"
    "%OUTPUT_DIR%"
    "%TEMP_DIR%"
    "%LOG_DIR%"
    "%CODECS_DIR%"
    "%PRESETS_DIR%"
    "%LUTS_DIR%"
    "%TRANSFORMS_DIR%"
    "%PALETTES_DIR%"
) do (if not exist "%%~D" mkdir "%%~D")


:: ----------------------------------------------------------------------------
:: Проверка обязательных файлов
:: ----------------------------------------------------------------------------
call :CheckFile "%FFMPEG%"  "ffmpeg.exe"  || exit /b 1
call :CheckFile "%FFPROBE%" "ffprobe.exe" || exit /b 1


:: ----------------------------------------------------------------------------
:: Проверка FFplay (необязательный компонент)
:: ----------------------------------------------------------------------------
if exist "%FFPLAY%" (set "HAS_FFPLAY=1") else (set "HAS_FFPLAY=0")


:: ----------------------------------------------------------------------------
:: Проверка VidStab (необязательные фильтры)
:: ----------------------------------------------------------------------------
set "HAS_VIDSTABDETECT=0"
set "HAS_VIDSTABTRANSFORM=0"
set "HAS_VIDSTAB=0"

"%FFMPEG%" -hide_banner -filters 2>nul | findstr /i "vidstabdetect" >nul && set "HAS_VIDSTABDETECT=1"
"%FFMPEG%" -hide_banner -filters 2>nul | findstr /i "vidstabtransform" >nul && set "HAS_VIDSTABTRANSFORM=1"

if "%HAS_VIDSTABDETECT%"=="1" if "%HAS_VIDSTABTRANSFORM%"=="1" set "HAS_VIDSTAB=1"


:: ----------------------------------------------------------------------------
:: Проверка редких image encoders (зависят от конкретной сборки FFmpeg)
:: ----------------------------------------------------------------------------
set "HAS_DDS_ENCODER=0"
set "HAS_PSD_ENCODER=0"
set "HAS_CINEON_ENCODER=0"

"%FFMPEG%" -hide_banner -encoders 2>nul | findstr /i /c:" dds " >nul && set "HAS_DDS_ENCODER=1"
"%FFMPEG%" -hide_banner -encoders 2>nul | findstr /i /c:" psd " >nul && set "HAS_PSD_ENCODER=1"
"%FFMPEG%" -hide_banner -encoders 2>nul | findstr /i /c:" cineon " >nul && set "HAS_CINEON_ENCODER=1"


:: ----------------------------------------------------------------------------
:: Определение версии FFmpeg
:: ----------------------------------------------------------------------------
set "FFMPEG_VERSION=unknown"

for /f "tokens=1,2,3" %%A in ('"%FFMPEG%" -version 2^>nul') do (
    if /I "%%A %%B"=="ffmpeg version" (
        set "FFMPEG_VERSION=%%C"
        goto :VersionDetected
    )
)

:VersionDetected


:: ----------------------------------------------------------------------------
:: Флаг успешной загрузки конфигурации
:: ----------------------------------------------------------------------------
set "CONFIG_LOADED=1"


:: ----------------------------------------------------------------------------
:: Экспорт переменных в вызывающий скрипт
:: ----------------------------------------------------------------------------
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
    set "CODECS_DIR=%CODECS_DIR%"
    set "PRESETS_DIR=%PRESETS_DIR%"
    set "LUTS_DIR=%LUTS_DIR%"
    set "SELECTORS_DIR=%SELECTORS_DIR%"
    set "TRANSFORMS_DIR=%TRANSFORMS_DIR%"
    set "PALETTES_DIR=%PALETTES_DIR%"

    set "FFMPEG_GLOBAL_OPTIONS=%FFMPEG_GLOBAL_OPTIONS%"
    set "FFPROBE_GLOBAL_OPTIONS=%FFPROBE_GLOBAL_OPTIONS%"
    set "FFPLAY_GLOBAL_OPTIONS=%FFPLAY_GLOBAL_OPTIONS%"

    set "HAS_FFPLAY=%HAS_FFPLAY%"
    set "HAS_VIDSTAB=%HAS_VIDSTAB%"
    set "HAS_VIDSTABDETECT=%HAS_VIDSTABDETECT%"
    set "HAS_VIDSTABTRANSFORM=%HAS_VIDSTABTRANSFORM%"
    set "HAS_DDS_ENCODER=%HAS_DDS_ENCODER%"
    set "HAS_PSD_ENCODER=%HAS_PSD_ENCODER%"
    set "HAS_CINEON_ENCODER=%HAS_CINEON_ENCODER%"
    set "FFMPEG_VERSION=%FFMPEG_VERSION%"
    set "CONFIG_LOADED=%CONFIG_LOADED%"
)

exit /b 0


:: ============================================================================
:: :CheckFile
:: Проверяет существование файла.
::
:: Аргументы:
::   %~1 - полный путь к файлу
::   %~2 - отображаемое имя файла
:: ============================================================================
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
