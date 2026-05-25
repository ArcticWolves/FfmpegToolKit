@echo off
setlocal EnableExtensions

set "BITRATE=1M"
set "CRF=10"

echo.
set /p "BITRATE=Video bitrate [1M]: "
if not defined BITRATE set "BITRATE=1M"
set /p "CRF=CRF quality [10]: "
if not defined CRF set "CRF=10"

set "VIDEO_CODEC=libvpx"
set "VIDEO_CODEC_OPTIONS=-crf %CRF% -b:v %BITRATE% -pix_fmt yuv420p"

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
