@echo off
setlocal EnableExtensions

set "COMPRESSION=8"

echo.
set /p "COMPRESSION=Compression level 0-12 [8]: "
if not defined COMPRESSION set "COMPRESSION=8"

set "AUDIO_CODEC=flac"
set "AUDIO_CODEC_OPTIONS=-compression_level %COMPRESSION%"

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
