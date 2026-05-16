@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_video_codec.bat
rem
rem Возвращает:
rem   VIDEO_CODEC
rem   VIDEO_CODEC_OPTIONS
rem
rem Используются только кодеки, доступные в LGPL-сборке.
rem ============================================================

:MAIN_MENU
cls

echo ============================================================
echo                    Выбор видеокодека
echo ============================================================
echo.
echo  1. Copy   (без перекодирования)
echo  2. AV1    (libaom-av1)
echo  3. VP9    (libvpx-vp9)
echo  4. VP8    (libvpx)
echo  5. Theora (libtheora)
echo  6. MPEG-4 (mpeg4)
echo.
echo  0. Отмена
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите видеокодек: "

if "%CHOICE%"=="1" goto CODEC_COPY
if "%CHOICE%"=="2" goto CODEC_AV1
if "%CHOICE%"=="3" goto CODEC_VP9
if "%CHOICE%"=="4" goto CODEC_VP8
if "%CHOICE%"=="5" goto CODEC_THEORA
if "%CHOICE%"=="6" goto CODEC_MPEG4
if "%CHOICE%"=="0" goto CANCEL

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU

:CODEC_COPY
set "VIDEO_CODEC=copy"
set "VIDEO_CODEC_OPTIONS="
goto SUCCESS

:CODEC_AV1
set "VIDEO_CODEC=libaom-av1"
set "VIDEO_CODEC_OPTIONS=-crf 30 -b:v 0"
goto SUCCESS

:CODEC_VP9
set "VIDEO_CODEC=libvpx-vp9"
set "VIDEO_CODEC_OPTIONS=-crf 30 -b:v 0"
goto SUCCESS

:CODEC_VP8
set "VIDEO_CODEC=libvpx"
set "VIDEO_CODEC_OPTIONS=-crf 10 -b:v 1M"
goto SUCCESS

:CODEC_THEORA
set "VIDEO_CODEC=libtheora"
set "VIDEO_CODEC_OPTIONS=-q:v 7"
goto SUCCESS

:CODEC_MPEG4
set "VIDEO_CODEC=mpeg4"
set "VIDEO_CODEC_OPTIONS=-q:v 2"
goto SUCCESS

:CANCEL
endlocal & (
    set "VIDEO_CODEC="
    set "VIDEO_CODEC_OPTIONS="
)
exit /b 1

:SUCCESS
endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0