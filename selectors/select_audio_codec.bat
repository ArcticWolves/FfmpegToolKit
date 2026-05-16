@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_audio_codec.bat
rem
rem Возвращает:
rem   AUDIO_CODEC
rem   AUDIO_CODEC_OPTIONS
rem
rem Используются только кодеки, доступные в LGPL-сборке.
rem ============================================================

:MAIN_MENU
cls

echo ============================================================
echo                    Выбор аудиокодека
echo ============================================================
echo.
echo  1. Copy      (без перекодирования)
echo  2. Opus      (libopus)
echo  3. Vorbis    (libvorbis)
echo  4. FLAC      (flac)
echo  5. WAV PCM   (pcm_s16le)
echo.
echo  0. Отмена
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if "%CHOICE%"=="1" goto CODEC_COPY
if "%CHOICE%"=="2" goto CODEC_OPUS
if "%CHOICE%"=="3" goto CODEC_VORBIS
if "%CHOICE%"=="4" goto CODEC_FLAC
if "%CHOICE%"=="5" goto CODEC_PCM
if "%CHOICE%"=="0" goto CANCEL

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU

:CODEC_COPY
set "AUDIO_CODEC=copy"
set "AUDIO_CODEC_OPTIONS="
goto SUCCESS

:CODEC_OPUS
set "AUDIO_CODEC=libopus"
set "AUDIO_CODEC_OPTIONS=-b:a 160k"
goto SUCCESS

:CODEC_VORBIS
set "AUDIO_CODEC=libvorbis"
set "AUDIO_CODEC_OPTIONS=-q:a 5"
goto SUCCESS

:CODEC_FLAC
set "AUDIO_CODEC=flac"
set "AUDIO_CODEC_OPTIONS="
goto SUCCESS

:CODEC_PCM
set "AUDIO_CODEC=pcm_s16le"
set "AUDIO_CODEC_OPTIONS="
goto SUCCESS

:CANCEL
endlocal & (
    set "AUDIO_CODEC="
    set "AUDIO_CODEC_OPTIONS="
)
exit /b 1

:SUCCESS
endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0