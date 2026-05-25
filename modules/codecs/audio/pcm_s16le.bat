@echo off
setlocal EnableExtensions

set "AUDIO_CODEC=pcm_s16le"
set "AUDIO_CODEC_OPTIONS="

endlocal & (
    set "AUDIO_CODEC=%AUDIO_CODEC%"
    set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0
