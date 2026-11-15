@rem @label PCM 32 бит float (WAV, обработка)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\pcm_f32le.bat
rem Несжатый PCM.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "AUDIO_CODEC=pcm_f32le"
set "AUDIO_CODEC_OPTIONS="
