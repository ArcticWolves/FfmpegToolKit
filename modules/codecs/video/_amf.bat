@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\_amf.bat
rem Общие настройки AMD AMF для h264_amf / hevc_amf / av1_amf.
rem Постоянный квантизатор (CQP).
rem %1 = энкодер, %2 = auto
rem ------------------------------------------------------------
set "_q=22"
if /i "%~1"=="av1_amf" set "_q=30"
if /i not "%~2"=="auto" call "%LIB%" :AskInt _q "QP 0-51, меньше = лучше" %_q% 0 51
set "_extra="
if /i "%~1"=="h264_amf" set "_extra= -qp_b %_q%"
set "_tag="
if /i "%~1"=="hevc_amf" (
    if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
    if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
)
set "VIDEO_CODEC=%~1"
set "VIDEO_CODEC_OPTIONS=-quality quality -rc cqp -qp_i %_q% -qp_p %_q%%_extra% -pix_fmt nv12%_tag%"
