@rem @label Vorbis (OGG/WebM)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\audio\libvorbis.bat
rem libvorbis, переменный битрейт по качеству.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: AUDIO_CODEC, AUDIO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=5"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "Качество 0-10, больше = лучше" 5 0 10
set "AUDIO_CODEC=libvorbis"
set "AUDIO_CODEC_OPTIONS=-q:a %_q%"
