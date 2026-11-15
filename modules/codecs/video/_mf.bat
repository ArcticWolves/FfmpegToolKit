@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\_mf.bat
rem Windows Media Foundation (h264_mf / hevc_mf): встроенный в Windows
rem энкодер, использует видеокарту, если она есть. Работает по битрейту.
rem %1 = энкодер, %2 = auto
rem ------------------------------------------------------------
set "_b=8M"
if /i "%~1"=="hevc_mf" set "_b=5M"
if /i not "%~2"=="auto" call "%LIB%" :AskBitrate _b "Битрейт видео" %_b%
set "_tag="
if /i "%~1"=="hevc_mf" (
    if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
    if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
)
set "VIDEO_CODEC=%~1"
set "VIDEO_CODEC_OPTIONS=-b:v %_b% -pix_fmt nv12%_tag%"
