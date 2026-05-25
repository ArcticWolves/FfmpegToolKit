@echo off
setlocal EnableExtensions

set "BITRATE=128k"

echo.
set /p "BITRATE=Audio bitrate [128k]: "
if not defined BITRATE set "BITRATE=128k"

set "AUDIO_CODEC=libopus"
set "AUDIO_CODEC_OPTIONS=-b:a %BITRATE%"

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
