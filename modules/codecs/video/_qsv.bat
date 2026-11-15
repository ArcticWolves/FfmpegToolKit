@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\_qsv.bat
rem Общие настройки Intel Quick Sync для h264_qsv / hevc_qsv / av1_qsv.
rem %1 = энкодер, %2 = auto
rem ------------------------------------------------------------
set "_q=23"
set "_p=medium"
if /i not "%~2"=="auto" call "%LIB%" :AskInt _q "global_quality 1-51, меньше = лучше" 23 1 51
if /i not "%~2"=="auto" call "%LIB%" :AskPick _p "Пресет veryfast..veryslow" medium "veryfast faster fast medium slow slower veryslow"
set "_tag="
if /i "%~1"=="hevc_qsv" (
    if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
    if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
)
set "VIDEO_CODEC=%~1"
set "VIDEO_CODEC_OPTIONS=-preset %_p% -global_quality %_q% -pix_fmt nv12%_tag%"
