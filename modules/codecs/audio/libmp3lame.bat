@rem @label MP3 - LAME (VBR)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\libmp3lame.bat
rem libmp3lame, переменный битрейт по качеству.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=2"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "VBR 0-9, меньше = лучше (0 ~ 245k, 2 ~ 190k)" 2 0 9
set "AUDIO_CODEC=libmp3lame"
set "AUDIO_CODEC_OPTIONS=-q:a %_q%"
