@echo off
setlocal EnableExtensions

set "QUALITY=2"

echo.
set /p "QUALITY=Quality scale [2]: "
if not defined QUALITY set "QUALITY=2"

set "VIDEO_CODEC=mpeg4"
set "VIDEO_CODEC_OPTIONS=-q:v %QUALITY%"

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
