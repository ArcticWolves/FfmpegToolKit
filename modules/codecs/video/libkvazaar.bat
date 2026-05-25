@echo off
setlocal EnableExtensions

set "BITRATE=5M"

echo.
set /p "BITRATE=Video bitrate [5M]: "
if not defined BITRATE set "BITRATE=5M"

set "VIDEO_CODEC=libkvazaar"
set "VIDEO_CODEC_OPTIONS=-b:v %BITRATE% -tag:v hvc1 -pix_fmt yuv420p"

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
