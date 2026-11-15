@echo off
rem ============================================================
rem modules\convert\aac.bat
rem Профиль конвертации: M4A (AAC)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=M4A (AAC)"
set "OUTPUT_EXT=m4a"
set "OUTPUT_SUFFIX=aac"
set "PREF_AUDIO=aac"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
