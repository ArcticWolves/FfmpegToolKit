@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_video_codec.bat
rem
rem Optional:
rem   TARGET_CONTAINER = mp4 | webm | ogv | any
rem Returns:
rem   VIDEO_CODEC
rem   VIDEO_CODEC_OPTIONS
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

if not defined TARGET_CONTAINER set "TARGET_CONTAINER=any"

if /I "%TARGET_CONTAINER%"=="mp4" goto MENU_MP4
if /I "%TARGET_CONTAINER%"=="webm" goto MENU_WEBM
if /I "%TARGET_CONTAINER%"=="ogv" goto MENU_OGV
goto MENU_ANY

:MENU_MP4
cls
echo ============================================================
echo                  Видеокодек для MP4
echo ============================================================
echo.
echo  1. Copy       (без перекодирования)
echo  2. H.264      (libopenh264)
echo  3. H.265/HEVC (libkvazaar)
echo  4. AV1        (libaom-av1)
echo  5. MPEG-4     (mpeg4)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите видеокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "video\copy.bat"       & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "video\libopenh264.bat" & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "video\libkvazaar.bat"  & goto SUCCESS
if "%CHOICE%"=="4" call :RunCodec "video\libaom-av1.bat"  & goto SUCCESS
if "%CHOICE%"=="5" call :RunCodec "video\mpeg4.bat"       & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_MP4

:INVALID_MP4
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_MP4

:MENU_WEBM
cls
echo ============================================================
echo                 Видеокодек для WebM
echo ============================================================
echo.
echo  1. Copy (без перекодирования)
echo  2. VP9  (libvpx-vp9)
echo  3. VP8  (libvpx)
echo  4. AV1  (libaom-av1)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите видеокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "video\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "video\libvpx-vp9.bat" & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "video\libvpx.bat"     & goto SUCCESS
if "%CHOICE%"=="4" call :RunCodec "video\libaom-av1.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_WEBM

:INVALID_WEBM
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_WEBM

:MENU_OGV
cls
echo ============================================================
echo                  Видеокодек для OGV
echo ============================================================
echo.
echo  1. Copy   (без перекодирования)
echo  2. Theora (libtheora)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите видеокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "video\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "video\libtheora.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_OGV

:INVALID_OGV
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_OGV

:MENU_ANY
cls
echo ============================================================
echo                    Выбор видеокодека
echo ============================================================
echo.
echo  1. Copy       (без перекодирования)
echo  2. H.264      (libopenh264)
echo  3. H.265/HEVC (libkvazaar)
echo  4. VP9        (libvpx-vp9)
echo  5. VP8        (libvpx)
echo  6. AV1        (libaom-av1)
echo  7. Theora     (libtheora)
echo  8. MPEG-4     (mpeg4)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите видеокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "video\copy.bat"       & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "video\libopenh264.bat" & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "video\libkvazaar.bat"  & goto SUCCESS
if "%CHOICE%"=="4" call :RunCodec "video\libvpx-vp9.bat"  & goto SUCCESS
if "%CHOICE%"=="5" call :RunCodec "video\libvpx.bat"      & goto SUCCESS
if "%CHOICE%"=="6" call :RunCodec "video\libaom-av1.bat"  & goto SUCCESS
if "%CHOICE%"=="7" call :RunCodec "video\libtheora.bat"   & goto SUCCESS
if "%CHOICE%"=="8" call :RunCodec "video\mpeg4.bat"       & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_ANY

:INVALID_ANY
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_ANY

:RunCodec
set "CODEC_MODULE=%CODECS_DIR%\%~1"
if not exist "%CODEC_MODULE%" (
    echo.
    echo [ERROR] Не найден модуль кодека:
    echo        %CODEC_MODULE%
    echo.
    pause
    exit /b 1
)

call "%CODEC_MODULE%"
exit /b %ERRORLEVEL%

:CANCEL
endlocal & (
    set "VIDEO_CODEC="
    set "VIDEO_CODEC_OPTIONS="
)
exit /b 1

:SUCCESS
if not defined VIDEO_CODEC goto CANCEL

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
