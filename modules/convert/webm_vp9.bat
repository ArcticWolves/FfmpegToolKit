@echo off
rem ============================================================
rem modules\convert\webm_vp9.bat
rem Профиль конвертации: WebM (VP9 + Opus)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=WebM (VP9 + Opus)"
set "OUTPUT_EXT=webm"
set "OUTPUT_SUFFIX=vp9"
set "PREF_VIDEO=libvpx-vp9 libsvtav1 libaom-av1"
set "PREF_AUDIO=libopus"
call "%TRANSCODE%"
