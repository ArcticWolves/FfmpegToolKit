@rem @label E-AC-3 / Dolby Digital Plus
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\eac3.bat
rem Встроенный энкодер eac3.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=384k"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт аудио" 384k
set "AUDIO_CODEC=eac3"
set "AUDIO_CODEC_OPTIONS=-b:a %_b%"
