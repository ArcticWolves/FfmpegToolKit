@rem @label HEVC - x265 (CPU, лучшее качество HEVC)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libx265.bat
rem H.265/HEVC через libx265 (только GPL-сборки FFmpeg).
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=24"
set "_p=medium"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 0-51, меньше = лучше" 24 0 51
if /i not "%~1"=="auto" call "%LIB%" :AskPick _p "Пресет ultrafast..veryslow" medium "ultrafast superfast veryfast faster fast medium slow slower veryslow"
set "_tag="
if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
set "VIDEO_CODEC=libx265"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -preset %_p% -pix_fmt yuv420p%_tag%"
