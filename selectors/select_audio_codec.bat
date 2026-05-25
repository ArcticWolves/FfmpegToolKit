@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem selectors\select_audio_codec.bat
rem
rem Optional:
rem   TARGET_CONTAINER = mp4 | m4a | mp3 | webm | ogv | ogg | opus | flac | wav | any
rem Returns:
rem   AUDIO_CODEC
rem   AUDIO_CODEC_OPTIONS
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
if /I "%TARGET_CONTAINER%"=="m4a" goto MENU_MP4
if /I "%TARGET_CONTAINER%"=="mp3" goto MENU_MP3
if /I "%TARGET_CONTAINER%"=="webm" goto MENU_WEBM
if /I "%TARGET_CONTAINER%"=="ogv" goto MENU_OGV
if /I "%TARGET_CONTAINER%"=="ogg" goto MENU_OGG
if /I "%TARGET_CONTAINER%"=="opus" goto MENU_OPUS
if /I "%TARGET_CONTAINER%"=="flac" goto MENU_FLAC
if /I "%TARGET_CONTAINER%"=="wav" goto MENU_WAV
goto MENU_ANY

:MENU_MP4
cls
echo ============================================================
echo                  Аудиокодек для MP4
echo ============================================================
echo.
echo  1. Copy (без перекодирования)
echo  2. AAC  (aac)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat" & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\aac.bat"  & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_MP4

:INVALID_MP4
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_MP4

:MENU_MP3
cls
echo ============================================================
echo                  Аудиокодек для MP3
echo ============================================================
echo.
echo  1. Copy (без перекодирования)
echo  2. MP3  (libmp3lame)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"       & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\libmp3lame.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_MP3

:INVALID_MP3
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_MP3

:MENU_WEBM
cls
echo ============================================================
echo                 Аудиокодек для WebM
echo ============================================================
echo.
echo  1. Copy   (без перекодирования)
echo  2. Opus   (libopus)
echo  3. Vorbis (libvorbis)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\libopus.bat"   & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "audio\libvorbis.bat" & goto SUCCESS
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
echo                  Аудиокодек для OGV
echo ============================================================
echo.
echo  1. Copy   (без перекодирования)
echo  2. Vorbis (libvorbis)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\libvorbis.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_OGV

:INVALID_OGV
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_OGV

:MENU_OGG
cls
echo ============================================================
echo                  Аудиокодек для OGG
echo ============================================================
echo.
echo  1. Copy   (без перекодирования)
echo  2. Vorbis (libvorbis)
echo  3. Opus   (libopus)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\libvorbis.bat" & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "audio\libopus.bat"   & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_OGG

:INVALID_OGG
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_OGG

:MENU_OPUS
cls
echo ============================================================
echo                 Аудиокодек для Opus
echo ============================================================
echo.
echo  1. Copy (без перекодирования)
echo  2. Opus (libopus)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"    & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\libopus.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_OPUS

:INVALID_OPUS
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_OPUS

:MENU_FLAC
cls
echo ============================================================
echo                 Аудиокодек для FLAC
echo ============================================================
echo.
echo  1. Copy (без перекодирования)
echo  2. FLAC (flac)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat" & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\flac.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_FLAC

:INVALID_FLAC
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_FLAC

:MENU_WAV
cls
echo ============================================================
echo                  Аудиокодек для WAV
echo ============================================================
echo.
echo  1. Copy    (без перекодирования)
echo  2. PCM 16  (pcm_s16le)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\pcm_s16le.bat" & goto SUCCESS
if "%CHOICE%"=="0" goto CANCEL
goto INVALID_WAV

:INVALID_WAV
echo.
echo [ERROR] Некорректный выбор.
pause
goto MENU_WAV

:MENU_ANY
cls
echo ============================================================
echo                    Выбор аудиокодека
echo ============================================================
echo.
echo  1. Copy      (без перекодирования)
echo  2. AAC       (aac)
echo  3. Opus      (libopus)
echo  4. Vorbis    (libvorbis)
echo  5. FLAC      (flac)
echo  6. WAV PCM   (pcm_s16le)
echo  7. MP3       (libmp3lame)
echo.
echo  0. Отмена
echo.
set "CHOICE="
set /p "CHOICE=Выберите аудиокодек: "

if not defined CHOICE goto CANCEL
if "%CHOICE%"=="1" call :RunCodec "audio\copy.bat"      & goto SUCCESS
if "%CHOICE%"=="2" call :RunCodec "audio\aac.bat"       & goto SUCCESS
if "%CHOICE%"=="3" call :RunCodec "audio\libopus.bat"   & goto SUCCESS
if "%CHOICE%"=="4" call :RunCodec "audio\libvorbis.bat" & goto SUCCESS
if "%CHOICE%"=="5" call :RunCodec "audio\flac.bat"      & goto SUCCESS
if "%CHOICE%"=="6" call :RunCodec "audio\pcm_s16le.bat" & goto SUCCESS
if "%CHOICE%"=="7" call :RunCodec "audio\libmp3lame.bat" & goto SUCCESS
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
    set "AUDIO_CODEC="
    set "AUDIO_CODEC_OPTIONS="
)
exit /b 1

:SUCCESS
if not defined AUDIO_CODEC goto CANCEL

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
