@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_edit_encode_profile.bat
rem
rem Selects an encode profile for edit modules that use filters.
rem
rem Optional:
rem   EDIT_ALLOW_AUDIO_COPY=0 disables audio stream copy
rem Returns:
rem   EDIT_VIDEO_CODEC
rem   EDIT_VIDEO_OPTIONS
rem   EDIT_AUDIO_CODEC
rem   EDIT_AUDIO_OPTIONS
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo.
    pause
    exit /b 1
)

if not defined EDIT_ALLOW_AUDIO_COPY set "EDIT_ALLOW_AUDIO_COPY=1"

:MAIN_MENU
cls
echo ============================================================
echo              Профиль кодирования для edit
echo ============================================================
echo.
if "%EDIT_ALLOW_AUDIO_COPY%"=="1" (
    echo  1. H.264 OpenH264 + копировать аудио
    echo  2. H.264 OpenH264 + AAC
    echo  3. H.265 libkvazaar + AAC
) else (
    echo  1. H.264 OpenH264 + AAC
    echo  2. H.265 libkvazaar + AAC
)
echo.
echo  0. Отмена
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите профиль: "

if "%CHOICE%"=="0" goto CANCEL

if "%EDIT_ALLOW_AUDIO_COPY%"=="1" (
    if "%CHOICE%"=="1" goto OPENH264_COPY
    if "%CHOICE%"=="2" goto OPENH264_AAC
    if "%CHOICE%"=="3" goto KVAAZAAR_AAC
) else (
    if "%CHOICE%"=="1" goto OPENH264_AAC
    if "%CHOICE%"=="2" goto KVAAZAAR_AAC
)

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU

:ASK_VIDEO_BITRATE
set "VIDEO_BITRATE="
set /p "VIDEO_BITRATE=Видео bitrate [%~1]: "
if not defined VIDEO_BITRATE set "VIDEO_BITRATE=%~1"
exit /b 0

:ASK_AUDIO_BITRATE
set "AUDIO_BITRATE="
set /p "AUDIO_BITRATE=Аудио bitrate [%~1]: "
if not defined AUDIO_BITRATE set "AUDIO_BITRATE=%~1"
exit /b 0

:OPENH264_COPY
call :ASK_VIDEO_BITRATE "5M"
set "EDIT_VIDEO_CODEC=libopenh264"
set "EDIT_VIDEO_OPTIONS=-b:v %VIDEO_BITRATE%"
set "EDIT_AUDIO_CODEC=copy"
set "EDIT_AUDIO_OPTIONS="
goto SUCCESS

:OPENH264_AAC
call :ASK_VIDEO_BITRATE "5M"
call :ASK_AUDIO_BITRATE "192k"
set "EDIT_VIDEO_CODEC=libopenh264"
set "EDIT_VIDEO_OPTIONS=-b:v %VIDEO_BITRATE%"
set "EDIT_AUDIO_CODEC=aac"
set "EDIT_AUDIO_OPTIONS=-b:a %AUDIO_BITRATE%"
goto SUCCESS

:KVAAZAAR_AAC
call :ASK_VIDEO_BITRATE "5M"
call :ASK_AUDIO_BITRATE "192k"
set "EDIT_VIDEO_CODEC=libkvazaar"
set "EDIT_VIDEO_OPTIONS=-b:v %VIDEO_BITRATE%"
set "EDIT_AUDIO_CODEC=aac"
set "EDIT_AUDIO_OPTIONS=-b:a %AUDIO_BITRATE%"
goto SUCCESS

:CANCEL
endlocal
exit /b 1

:SUCCESS
endlocal & (
    set "EDIT_VIDEO_CODEC=%EDIT_VIDEO_CODEC%"
    set "EDIT_VIDEO_OPTIONS=%EDIT_VIDEO_OPTIONS%"
    set "EDIT_AUDIO_CODEC=%EDIT_AUDIO_CODEC%"
    set "EDIT_AUDIO_OPTIONS=%EDIT_AUDIO_OPTIONS%"
)
exit /b 0
