@echo off
rem ============================================================
rem modules\convert\mp4_h264.bat
rem Профиль конвертации: MP4 (H.264 + AAC)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MP4 (H.264 + AAC)"
set "OUTPUT_EXT=mp4"
set "OUTPUT_SUFFIX=h264"
set "PREF_VIDEO=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "PREF_AUDIO=aac"
call "%TRANSCODE%"
