@echo off
setlocal EnableExtensions

set "QUALITY=2"

echo.
set /p "QUALITY=VBR quality 0-9, lower is better [2]: "
if not defined QUALITY set "QUALITY=2"

set "AUDIO_CODEC=libmp3lame"
set "AUDIO_CODEC_OPTIONS=-q:a %QUALITY%"

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
