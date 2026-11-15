@echo off
rem ============================================================
rem modules\convert\ogg.bat
rem Профиль конвертации: OGG (Vorbis)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=OGG (Vorbis)"
set "OUTPUT_EXT=ogg"
set "OUTPUT_SUFFIX=vorbis"
set "PREF_AUDIO=libvorbis"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
