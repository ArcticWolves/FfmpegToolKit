@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\info.bat
rem Информация о сборке FFmpeg: сводка возможностей, списки
rem кодеков/фильтров/форматов. Любой список можно сохранить в
rem temp\logs.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Информация о сборке FFmpeg"
echo   1. Сводка возможностей ToolKit для этой сборки
echo   2. Версия            7. Аппаратное ускорение (hwaccels)
echo   3. Конфигурация      8. Форматы (контейнеры)
echo   4. Кодеки            9. Протоколы
echo   5. Энкодеры         10. Устройства
echo   6. Фильтры          11. Лицензия
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите пункт"
set "ARG="
if "%CHOICE%"=="1" goto SUMMARY
if "%CHOICE%"=="2"  set "ARG=-version"
if "%CHOICE%"=="3"  set "ARG=-buildconf"
if "%CHOICE%"=="4"  set "ARG=-codecs"
if "%CHOICE%"=="5"  set "ARG=-encoders"
if "%CHOICE%"=="6"  set "ARG=-filters"
if "%CHOICE%"=="7"  set "ARG=-hwaccels"
if "%CHOICE%"=="8"  set "ARG=-formats"
if "%CHOICE%"=="9"  set "ARG=-protocols"
if "%CHOICE%"=="10" set "ARG=-devices"
if "%CHOICE%"=="11" set "ARG=-L"
if "%CHOICE%"=="0" goto EXIT_MODULE
if not defined ARG (call "%LIB%" :InvalidChoice & goto MAIN_MENU)

set "LOG_FILE="
call "%LIB%" :AskYN "Сохранить вывод в temp\logs?" N
if not errorlevel 1 (
    call "%LIB%" :Timestamp TS
    set "LOG_FILE=%LOG_DIR%\ffmpeg%ARG%_!TS!.txt"
)
cls
if defined LOG_FILE (
    "%FFMPEG%" -hide_banner %ARG% > "!LOG_FILE!" 2>&1
    echo Сохранено: !LOG_FILE!
    call "%LIB%" :AskYN "Открыть в Блокноте?" Y
    if not errorlevel 1 start "" notepad "!LOG_FILE!"
) else (
    "%FFMPEG%" -hide_banner %ARG% | more
    pause
)
goto MAIN_MENU


rem ------------------------------------------------------------
rem Сводка: что доступно и почему чего-то нет
rem ------------------------------------------------------------
:SUMMARY
call "%LIB%" :Header "Возможности этой сборки"
echo FFmpeg %FFMPEG_VERSION%, лицензия сборки: %FFMPEG_LICENSE%
echo.
echo Видеокодеки (* - есть):
call :Row "H.264 " "libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
call :Row "HEVC  " "libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar"
call :Row "AV1   " "libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e"
call :Row "Прочие" "libvvenc libvpx-vp9 libvpx libtheora prores_ks dnxhd ffv1 utvideo mpeg4 mpeg2video"
echo Аудиокодеки:
call :Row "      " "aac libopus libvorbis libmp3lame flac alac ac3 eac3"
echo Изображения:
call :Row "      " "png mjpeg libwebp libaom-av1 libjxl tiff bmp qoi dpx exr hdr jpeg2000"
echo.
echo Фильтры:
call :FRow "      " "vidstabdetect deshake eq hqdn3d nlmeans unsharp bwdif lut3d drawtext subtitles"
call :FRow "      " "loudnorm afftdn whisper libvmaf minterpolate showwavespic gblur colortemperature"
echo.
if not "%FFMPEG_LICENSE%"=="GPL" (
    echo Сборка без GPL-компонентов. Недоступны: libx264, libx265, vidstab,
    echo eq, hqdn3d и другие GPL-фильтры. ToolKit автоматически использует
    echo замены: OpenH264/Kvazaar/Media Foundation/NVENC/QSV/AMF, deshake,
    echo lutyuv+hue, nlmeans/atadenoise.
    echo Для максимума возможностей положите в source\bin GPL-сборку
    echo ^(BtbN: ffmpeg-master-latest-win64-gpl-shared^) и нажмите R
    echo в главном меню. Подробнее про лицензии: Readme.txt
)
echo.
pause
goto MAIN_MENU

:Row
set "_line=  %~1 :"
for %%E in (%~2) do (
    if defined HAS_ENC_%%E (set "_line=!_line! *%%E") else (set "_line=!_line!  %%E")
)
echo !_line!
exit /b 0

:FRow
set "_line=  %~1 :"
for %%E in (%~2) do (
    if defined HAS_FLT_%%E (set "_line=!_line! *%%E") else (set "_line=!_line!  %%E")
)
echo !_line!
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
