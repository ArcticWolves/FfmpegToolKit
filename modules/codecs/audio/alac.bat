@rem @label ALAC - Apple Lossless (без потерь, M4A)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\alac.bat
rem Встроенный энкодер alac.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "AUDIO_CODEC=alac"
set "AUDIO_CODEC_OPTIONS="
