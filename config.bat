@echo off
rem ============================================================================
rem config.bat
rem Центральная конфигурация FFmpeg ToolKit.
rem
rem Назначение:
rem   - Определить корень проекта и пути к ffmpeg / ffprobe / ffplay.
rem   - Создать рабочие каталоги.
rem   - Определить возможности текущей сборки FFmpeg (кодеки, фильтры,
rem     аппаратные энкодеры) и закэшировать результат.
rem
rem Важно:
rem   Требуется включённый EnableDelayedExpansion у вызывающего скрипта.
rem   Скрипт НЕ использует setlocal: все переменные остаются в окружении
rem   вызывающего скрипта (FFmpegToolkit.bat держит их в своём setlocal).
rem   Временные переменные имеют префикс _cfg_ и удаляются в конце.
rem
rem Кэш: temp\caps\flags.bat. Пересоздаётся при замене ffmpeg.exe
rem или по пункту R в главном меню.
rem
rem Флаги возможностей:
rem   HAS_ENC_<энкодер>=1     например HAS_ENC_libx264, HAS_ENC_h264_nvenc
rem   HAS_FLT_<фильтр>=1      например HAS_FLT_vidstabdetect, HAS_FLT_eq
rem   HAS_DEV_<устройство>=1  gdigrab (экран), dshow (камеры/микрофоны)
rem   Аппаратные энкодеры (nvenc/qsv/amf/mf) проверяются пробным кодированием,
rem   поэтому флаг ставится, только если энкодер реально работает на этом ПК.
rem ============================================================================

rem ----------------------------------------------------------------------------
rem Корень проекта (без завершающего "\")
rem ----------------------------------------------------------------------------
for %%I in ("%~dp0.") do set "ROOT=%%~fI"

rem ----------------------------------------------------------------------------
rem Исполняемые файлы FFmpeg
rem ----------------------------------------------------------------------------
set "FFMPEG=%ROOT%\source\bin\ffmpeg.exe"
set "FFPROBE=%ROOT%\source\bin\ffprobe.exe"
set "FFPLAY=%ROOT%\source\bin\ffplay.exe"

rem ----------------------------------------------------------------------------
rem Каталоги проекта
rem ----------------------------------------------------------------------------
set "INPUT_DIR=%ROOT%\input"
set "OUTPUT_DIR=%ROOT%\output"
set "TEMP_DIR=%ROOT%\temp"
set "LOG_DIR=%TEMP_DIR%\logs"
set "CAPS_DIR=%TEMP_DIR%\caps"
set "TRANSFORMS_DIR=%TEMP_DIR%\transforms"
set "MODULES_DIR=%ROOT%\modules"
set "CODECS_DIR=%MODULES_DIR%\codecs"
set "SELECTORS_DIR=%ROOT%\selectors"
set "LUTS_DIR=%ROOT%\luts"
set "MODELS_DIR=%ROOT%\models"
set "LIB=%ROOT%\lib\common.bat"
set "TRANSCODE=%ROOT%\lib\transcode.bat"
set "HISTORY_FILE=%LOG_DIR%\history.log"

rem ----------------------------------------------------------------------------
rem Глобальные параметры
rem ----------------------------------------------------------------------------
set "FFMPEG_GLOBAL_OPTIONS=-hide_banner -y"
set "FFPROBE_GLOBAL_OPTIONS=-v error"
set "FFPLAY_GLOBAL_OPTIONS=-hide_banner -loglevel error"

rem Расширения медиафайлов (выбор файла, пакетная обработка, склейка).
set "MEDIA_EXTENSIONS=.mp4 .mkv .mov .avi .webm .m4v .ts .mts .m2ts .flv .wmv .mpg .mpeg .ogv .3gp .gif .mp3 .wav .flac .m4a .aac .ogg .opus .wma .aiff .aif .ac3 .png .jpg .jpeg .bmp .webp .tif .tiff"

rem ----------------------------------------------------------------------------
rem Рабочие каталоги
rem ----------------------------------------------------------------------------
for %%D in ("%INPUT_DIR%" "%OUTPUT_DIR%" "%TEMP_DIR%" "%LOG_DIR%" "%CAPS_DIR%" "%TRANSFORMS_DIR%" "%LUTS_DIR%" "%MODELS_DIR%") do (
    if not exist "%%~D" mkdir "%%~D"
)

rem ----------------------------------------------------------------------------
rem Обязательные файлы
rem ----------------------------------------------------------------------------
call :CheckFile "%FFMPEG%" "ffmpeg.exe"
if errorlevel 1 exit /b 1
call :CheckFile "%FFPROBE%" "ffprobe.exe"
if errorlevel 1 exit /b 1
call :CheckFile "%LIB%" "lib\common.bat"
if errorlevel 1 exit /b 1

if exist "%FFPLAY%" (set "HAS_FFPLAY=1") else (set "HAS_FFPLAY=0")

rem ----------------------------------------------------------------------------
rem Версия FFmpeg
rem ----------------------------------------------------------------------------
set "FFMPEG_VERSION=unknown"
for /f "tokens=1-3" %%A in ('""%FFMPEG%" -hide_banner -version 2>nul"') do (
    if /I "%%A %%B"=="ffmpeg version" (set "FFMPEG_VERSION=%%C" & goto VersionDone)
)
:VersionDone

rem ----------------------------------------------------------------------------
rem Списки имён, для которых ставятся флаги возможностей
rem ----------------------------------------------------------------------------
set "_cfg_encoders=libx264 libx265 libsvtav1 libaom-av1 librav1e libvvenc libopenh264 libkvazaar libvpx libvpx-vp9 libtheora mpeg4 mpeg2video ffv1 prores_ks dnxhd utvideo mjpeg png apng gif bmp tiff dpx exr hdr pam pbm pgm ppm qoi jpeg2000 libopenjpeg libwebp libwebp_anim libjxl libjxl_anim dds psd cineon aac alac ac3 eac3 flac libmp3lame libopus libvorbis pcm_s16le pcm_s24le pcm_f32le srt ass mov_text webvtt"
set "HW_ENCODERS=h264_nvenc hevc_nvenc av1_nvenc h264_qsv hevc_qsv av1_qsv h264_amf hevc_amf av1_amf h264_mf hevc_mf"
set "_cfg_filters=vidstabdetect vidstabtransform deshake eq hqdn3d nlmeans atadenoise unsharp cas bwdif yadif lut3d huesaturation hue curves colortemperature colorbalance vignette gblur drawtext subtitles loudnorm dynaudnorm afftdn anlmdn whisper libvmaf minterpolate reverse areverse tile thumbnail showwavespic showspectrumpic scdet palettegen paletteuse"
set "_cfg_devices=gdigrab dshow"

rem ----------------------------------------------------------------------------
rem Кэш возможностей: пересоздаётся, если изменился ffmpeg.exe или схема кэша
rem ----------------------------------------------------------------------------
set "_cfg_schema=4"
for %%F in ("%FFMPEG%") do set "_cfg_stamp=%_cfg_schema%_%%~zF_%%~tF"
set "_cfg_old="
if exist "%CAPS_DIR%\stamp.txt" set /p "_cfg_old=" < "%CAPS_DIR%\stamp.txt"
if not exist "%CAPS_DIR%\flags.bat" set "_cfg_old="
if not "%_cfg_old%"=="%_cfg_stamp%" call :BuildCapsCache

for %%N in (%_cfg_encoders% %HW_ENCODERS%) do set "HAS_ENC_%%N="
for %%N in (%_cfg_filters%) do set "HAS_FLT_%%N="
for %%N in (%_cfg_devices%) do set "HAS_DEV_%%N="
call "%CAPS_DIR%\flags.bat"

rem ----------------------------------------------------------------------------
rem Производные флаги
rem ----------------------------------------------------------------------------
set "HAS_VIDSTAB=0"
if defined HAS_FLT_vidstabdetect if defined HAS_FLT_vidstabtransform set "HAS_VIDSTAB=1"

set "FFMPEG_LICENSE=LGPL"
findstr /c:"--enable-gpl" "%CAPS_DIR%\buildconf.txt" >nul 2>&1
if not errorlevel 1 set "FFMPEG_LICENSE=GPL"
findstr /c:"--enable-nonfree" "%CAPS_DIR%\buildconf.txt" >nul 2>&1
if not errorlevel 1 set "FFMPEG_LICENSE=nonfree - нельзя распространять"

for %%V in (_cfg_schema _cfg_stamp _cfg_old _cfg_encoders _cfg_filters _cfg_devices) do set "%%V="

set "CONFIG_LOADED=1"
exit /b 0


rem ============================================================================
rem :BuildCapsCache
rem Сохраняет списки энкодеров/фильтров/устройств, формирует flags.bat
rem и проверяет аппаратные энкодеры пробным кодированием.
rem ============================================================================
:BuildCapsCache
echo.
echo [INFO] Анализ возможностей сборки FFmpeg (первый запуск
echo        или замена ffmpeg.exe). Это займёт несколько секунд...
"%FFMPEG%" -hide_banner -encoders  > "%CAPS_DIR%\encoders.txt"  2>nul
"%FFMPEG%" -hide_banner -filters   > "%CAPS_DIR%\filters.txt"   2>nul
"%FFMPEG%" -hide_banner -devices   > "%CAPS_DIR%\devices.txt"   2>nul
"%FFMPEG%" -hide_banner -buildconf > "%CAPS_DIR%\buildconf.txt" 2>nul

> "%CAPS_DIR%\flags.bat" echo @rem Generated by config.bat - do not edit
call :CollectNames HAS_ENC_ "%CAPS_DIR%\encoders.txt" "%_cfg_encoders%"
call :CollectNames HAS_FLT_ "%CAPS_DIR%\filters.txt" "%_cfg_filters%"
call :CollectNames HAS_DEV_ "%CAPS_DIR%\devices.txt" "%_cfg_devices%"

for %%E in (%HW_ENCODERS%) do (
    findstr /c:" %%E " "%CAPS_DIR%\encoders.txt" >nul 2>&1
    if not errorlevel 1 call :ProbeHwEncoder %%E
)

> "%CAPS_DIR%\stamp.txt" echo %_cfg_stamp%
exit /b 0


rem ============================================================================
rem :CollectNames  %1 = префикс флага, %2 = список ffmpeg, %3 = нужные имена
rem Берёт второй столбец списка (имя энкодера/фильтра/устройства) и для
rem нужных имён дописывает в flags.bat строку:  set "<префикс><имя>=1"
rem ============================================================================
:CollectNames
for /f "usebackq tokens=1,2" %%A in ("%~2") do (
    for %%W in (%~3) do if "%%W"=="%%B" >> "%CAPS_DIR%\flags.bat" echo set "%~1%%B=1"
)
exit /b 0


rem ============================================================================
rem :ProbeHwEncoder  %1 = энкодер
rem Кодирует 0.2 с чёрного кадра. FFmpeg может вернуть отрицательный код
rem ошибки, поэтому проверяется именно "не 0", а не "errorlevel 1".
rem ============================================================================
:ProbeHwEncoder
echo [INFO]   проверка %1 ...
"%FFMPEG%" -hide_banner -loglevel quiet -f lavfi -i "color=c=black:s=640x360:r=30:d=0.2" -c:v %1 -f null - >nul 2>&1
if not "%errorlevel%"=="0" exit /b 0
>> "%CAPS_DIR%\flags.bat" echo set "HAS_ENC_%1=1"
exit /b 0


rem ============================================================================
rem :CheckFile  %1 = путь, %2 = отображаемое имя
rem ============================================================================
:CheckFile
if exist "%~1" exit /b 0
echo.
echo [ERROR] Не найден %~2
echo [ERROR] Ожидаемый путь:
echo         %~1
echo.
echo Скачайте сборку FFmpeg (win64, shared) и скопируйте содержимое её
echo папки bin в source\bin. Подробнее: Readme.txt
echo.
pause
exit /b 1
