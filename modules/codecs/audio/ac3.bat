@rem @label AC-3 / Dolby Digital
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\ac3.bat
rem Встроенный энкодер ac3.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=448k"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт аудио" 448k
set "AUDIO_CODEC=ac3"
set "AUDIO_CODEC_OPTIONS=-b:a %_b%"
