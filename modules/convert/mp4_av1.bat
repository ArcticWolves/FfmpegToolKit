@echo off
rem ============================================================
rem modules\convert\mp4_av1.bat
rem Профиль конвертации: MP4 (AV1 + AAC)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MP4 (AV1 + AAC)"
set "OUTPUT_EXT=mp4"
set "OUTPUT_SUFFIX=av1"
set "PREF_VIDEO=libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e"
set "PREF_AUDIO=aac"
call "%TRANSCODE%"
