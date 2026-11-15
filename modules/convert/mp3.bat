@echo off
rem ============================================================
rem modules\convert\mp3.bat
rem Профиль конвертации: MP3
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MP3"
set "OUTPUT_EXT=mp3"
set "OUTPUT_SUFFIX=mp3"
set "PREF_AUDIO=libmp3lame"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
