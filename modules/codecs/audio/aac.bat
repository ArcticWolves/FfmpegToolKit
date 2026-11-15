@rem @label AAC (универсальный, MP4/M4A)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\aac.bat
rem Встроенный энкодер aac.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=192k"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт аудио" 192k
set "AUDIO_CODEC=aac"
set "AUDIO_CODEC_OPTIONS=-b:a %_b%"
