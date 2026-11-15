@echo off
rem ============================================================
rem modules\convert\alac.bat
rem Профиль конвертации: M4A (ALAC, без потерь)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=M4A (ALAC, без потерь)"
set "OUTPUT_EXT=m4a"
set "OUTPUT_SUFFIX=alac"
set "PREF_AUDIO=alac"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
