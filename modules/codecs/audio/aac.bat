@echo off
setlocal EnableExtensions

set "BITRATE=192k"

echo.
set /p "BITRATE=Audio bitrate [192k]: "
if not defined BITRATE set "BITRATE=192k"

set "AUDIO_CODEC=aac"
set "AUDIO_CODEC_OPTIONS=-b:a %BITRATE%"

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
