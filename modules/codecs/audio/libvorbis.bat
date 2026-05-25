@echo off
setlocal EnableExtensions

set "QUALITY=5"

echo.
set /p "QUALITY=Quality 0-10 [5]: "
if not defined QUALITY set "QUALITY=5"

set "AUDIO_CODEC=libvorbis"
set "AUDIO_CODEC_OPTIONS=-q:a %QUALITY%"

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
