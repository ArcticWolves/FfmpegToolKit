@rem @label Copy - без перекодирования
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\copy.bat
rem Копирование аудиопотока как есть.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "AUDIO_CODEC=copy"
set "AUDIO_CODEC_OPTIONS="
