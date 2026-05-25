@echo off
setlocal EnableExtensions

set "CRF=30"

echo.
set /p "CRF=CRF quality, lower is better [30]: "
if not defined CRF set "CRF=30"

set "VIDEO_CODEC=libvpx-vp9"
set "VIDEO_CODEC_OPTIONS=-crf %CRF% -b:v 0 -row-mt 1 -tile-columns 2 -frame-parallel 1 -pix_fmt yuv420p"

endlocal & (
    set "VIDEO_CODEC=%VIDEO_CODEC%"
    set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
)
exit /b 0
