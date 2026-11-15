@rem @label Theora - libtheora (для OGV)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libtheora.bat
rem Theora через libtheora.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=7"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "Качество 0-10, больше = лучше" 7 0 10
set "VIDEO_CODEC=libtheora"
set "VIDEO_CODEC_OPTIONS=-q:v %_q% -pix_fmt yuv420p"
