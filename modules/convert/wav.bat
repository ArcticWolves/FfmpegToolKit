@echo off
rem ============================================================
rem modules\convert\wav.bat
rem Профиль конвертации: WAV (PCM)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=WAV (PCM)"
set "OUTPUT_EXT=wav"
set "OUTPUT_SUFFIX=wav"
set "PREF_AUDIO=pcm_s16le"
set "ENC_NO_VIDEO=1"
call "%TRANSCODE%"
