@rem @label Opus (лучшее качество на битрейт)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\libopus.bat
rem libopus в режиме VBR.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=128k"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт аудио" 128k
set "AUDIO_CODEC=libopus"
set "AUDIO_CODEC_OPTIONS=-b:a %_b% -vbr on"
