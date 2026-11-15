@echo off
rem ============================================================
rem modules\convert\mov_prores.bat
rem Профиль конвертации: MOV (ProRes + PCM)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MOV (ProRes + PCM)"
set "OUTPUT_EXT=mov"
set "OUTPUT_SUFFIX=prores"
set "PREF_VIDEO=prores_ks"
set "PREF_AUDIO=pcm_s16le"
call "%TRANSCODE%"
