@rem @label AV1 - rav1e (CPU)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\librav1e.bat
rem AV1 через librav1e.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=100"
set "_p=6"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "QP 0-255, меньше = лучше" 100 0 255
if /i not "%~1"=="auto" call "%LIB%" :AskInt _p "Скорость 0-10, больше = быстрее" 6 0 10
set "VIDEO_CODEC=librav1e"
set "VIDEO_CODEC_OPTIONS=-qp %_q% -speed %_p% -pix_fmt yuv420p"
