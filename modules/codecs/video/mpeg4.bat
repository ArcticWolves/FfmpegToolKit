@rem @label MPEG-4 Part 2 (совместимость со старыми устройствами)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\mpeg4.bat
rem Встроенный энкодер mpeg4.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=3"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "Квантизатор 1-31, меньше = лучше" 3 1 31
set "VIDEO_CODEC=mpeg4"
set "VIDEO_CODEC_OPTIONS=-q:v %_q%"
