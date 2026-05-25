@echo off
setlocal EnableExtensions

set "VIDEO_CODEC=copy"
set "VIDEO_CODEC_OPTIONS="

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
