@echo off
rem ============================================================
rem modules\convert\mp4_h265.bat
rem Профиль конвертации: MP4 (HEVC + AAC)
rem Кодеки выбираются автоматически (лучшие доступные) и могут быть изменены на экране "Кодирование".
rem ============================================================
set "JOB_TITLE=MP4 (HEVC + AAC)"
set "OUTPUT_EXT=mp4"
set "OUTPUT_SUFFIX=hevc"
set "PREF_VIDEO=libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar"
set "PREF_AUDIO=aac"
call "%TRANSCODE%"
