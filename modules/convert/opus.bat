@echo off
rem ============================================================
rem modules\convert\opus.bat
rem Профиль конвертации: Opus
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=Opus"
set "OUTPUT_EXT=opus"
set "OUTPUT_SUFFIX=opus"
set "PREF_AUDIO=libopus"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
