@echo off
rem ============================================================
rem modules\convert\flac.bat
rem Профиль конвертации: FLAC
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=FLAC"
set "OUTPUT_EXT=flac"
set "OUTPUT_SUFFIX=flac"
set "PREF_AUDIO=flac"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
