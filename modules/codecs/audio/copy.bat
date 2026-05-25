@echo off
setlocal EnableExtensions

set "AUDIO_CODEC=copy"
set "AUDIO_CODEC_OPTIONS="

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
