@rem @label AV1 - libaom (CPU, эталонный, медленный)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libaom-av1.bat
rem AV1 через libaom.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=30"
set "_p=6"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 0-63, меньше = лучше" 30 0 63
if /i not "%~1"=="auto" call "%LIB%" :AskInt _p "cpu-used 0-8, больше = быстрее" 6 0 8
set "VIDEO_CODEC=libaom-av1"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -b:v 0 -cpu-used %_p% -row-mt 1 -pix_fmt yuv420p"
