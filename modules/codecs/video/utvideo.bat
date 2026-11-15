@rem @label UT Video - lossless (быстрый, для монтажа)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\utvideo.bat
rem Встроенный энкодер utvideo.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "VIDEO_CODEC=utvideo"
set "VIDEO_CODEC_OPTIONS=-pred median"
