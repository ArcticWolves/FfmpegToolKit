@echo off
rem ============================================================
rem modules\convert\mkv.bat
rem Профиль конвертации: MKV (H.264 + Opus)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MKV (H.264 + Opus)"
set "OUTPUT_EXT=mkv"
set "OUTPUT_SUFFIX=mkv"
set "PREF_VIDEO=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "PREF_AUDIO=libopus aac"
call "%TRANSCODE%"
