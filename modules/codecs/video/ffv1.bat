@rem @label FFV1 - lossless (архив без потерь)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\ffv1.bat
rem Встроенный энкодер FFV1 версии 3.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "VIDEO_CODEC=ffv1"
set "VIDEO_CODEC_OPTIONS=-level 3 -g 1 -slicecrc 1"
