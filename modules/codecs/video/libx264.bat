@rem @label H.264 - x264 (CPU, лучшее качество H.264)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libx264.bat
rem H.264 через libx264 (только GPL-сборки FFmpeg).
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=20"
set "_p=medium"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 0-51, меньше = лучше" 20 0 51
if /i not "%~1"=="auto" call "%LIB%" :AskPick _p "Пресет ultrafast..veryslow" medium "ultrafast superfast veryfast faster fast medium slow slower veryslow"
set "VIDEO_CODEC=libx264"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -preset %_p% -pix_fmt yuv420p"
