@rem @label MPEG-2 (DVD, ТВ)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\mpeg2video.bat
rem Встроенный энкодер mpeg2video.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=3"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "Квантизатор 1-31, меньше = лучше" 3 1 31
set "VIDEO_CODEC=mpeg2video"
set "VIDEO_CODEC_OPTIONS=-q:v %_q%"
