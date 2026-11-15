@rem @label PCM 24 бит (WAV, студийный)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\pcm_s24le.bat
rem Несжатый PCM.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "AUDIO_CODEC=pcm_s24le"
set "AUDIO_CODEC_OPTIONS="
