@rem @label PCM 16 бит (WAV, CD-качество)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\pcm_s16le.bat
rem Несжатый PCM.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "AUDIO_CODEC=pcm_s16le"
set "AUDIO_CODEC_OPTIONS="
