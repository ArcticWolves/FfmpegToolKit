@echo off
setlocal EnableExtensions

set "QUALITY=7"

echo.
set /p "QUALITY=Quality 0-10 [7]: "
if not defined QUALITY set "QUALITY=7"

set "VIDEO_CODEC=libtheora"
set "VIDEO_CODEC_OPTIONS=-q:v %QUALITY%"

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
