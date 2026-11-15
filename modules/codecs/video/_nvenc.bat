@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\_nvenc.bat
rem Общие настройки NVIDIA NVENC для h264_nvenc / hevc_nvenc / av1_nvenc.
rem %1 = энкодер, %2 = auto
rem ------------------------------------------------------------
set "_q=23"
set "_max=51"
if /i "%~1"=="av1_nvenc" (set "_q=30" & set "_max=63")
set "_p=p5"
if /i not "%~2"=="auto" call "%LIB%" :AskInt _q "CQ 0-%_max%, меньше = лучше" %_q% 0 %_max%
if /i not "%~2"=="auto" call "%LIB%" :AskPick _p "Пресет p1 (быстро) .. p7 (качество)" p5 "p1 p2 p3 p4 p5 p6 p7"
set "_tag="
if /i "%~1"=="hevc_nvenc" (
    if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
    if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
)
set "VIDEO_CODEC=%~1"
set "VIDEO_CODEC_OPTIONS=-preset %_p% -tune hq -rc vbr -cq %_q% -b:v 0 -pix_fmt yuv420p%_tag%"
