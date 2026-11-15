@rem @label VP9 - libvpx (CPU, для WebM)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libvpx-vp9.bat
rem VP9 через libvpx-vp9 в режиме постоянного качества.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=31"
set "_p=2"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 0-63, меньше = лучше" 31 0 63
if /i not "%~1"=="auto" call "%LIB%" :AskInt _p "cpu-used 0-5, больше = быстрее" 2 0 5
set "VIDEO_CODEC=libvpx-vp9"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -b:v 0 -deadline good -cpu-used %_p% -row-mt 1 -pix_fmt yuv420p"
