@rem @label FLAC (без потерь)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\flac.bat
rem Встроенный энкодер flac.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=8"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "Степень сжатия 0-12" 8 0 12
set "AUDIO_CODEC=flac"
set "AUDIO_CODEC_OPTIONS=-compression_level %_q%"
