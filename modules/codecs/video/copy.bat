@rem @label Copy - без перекодирования (быстро, без потерь)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\copy.bat
rem Копирование видеопотока как есть.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "VIDEO_CODEC=copy"
set "VIDEO_CODEC_OPTIONS="
