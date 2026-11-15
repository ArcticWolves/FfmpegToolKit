@echo off
rem ============================================================
rem modules\convert\ogv.bat
rem Профиль конвертации: OGV (Theora + Vorbis)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=OGV (Theora + Vorbis)"
set "OUTPUT_EXT=ogv"
set "OUTPUT_SUFFIX=theora"
set "PREF_VIDEO=libtheora"
set "PREF_AUDIO=libvorbis"
call "%TRANSCODE%"
