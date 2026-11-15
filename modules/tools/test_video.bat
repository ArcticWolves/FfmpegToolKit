@echo off
rem ============================================================
rem modules\tools\test_video.bat
rem Генерация тестового видео: таблица testsrc2 + тон 1 кГц.
rem ============================================================

call "%LIB%" :Header "Тестовое видео"
call "%LIB%" :AskInt DUR "Длительность, секунд" 10 1 3600
call "%LIB%" :AskPick SIZE "Размер: 1280x720, 1920x1080, 3840x2160" 1920x1080 "1280x720 1920x1080 3840x2160"
call "%LIB%" :AskInt FPS "Кадров в секунду" 30 1 120
set "OUTPUT_FILE=%OUTPUT_DIR%\test_%SIZE%_%FPS%fps.mp4"
set "TARGET_CONTAINER=mp4"
set "PREF_VIDEO=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "PREF_AUDIO=aac"
set "ENC_SILENT=1"
call "%SELECTORS_DIR%\select_encoding.bat"
set "FF_ARGS=-f lavfi -i "testsrc2=size=%SIZE%:rate=%FPS%:duration=%DUR%" -f lavfi -i "sine=frequency=1000:sample_rate=48000:duration=%DUR%" !ENC_ARGS! -shortest "!OUTPUT_FILE!""
call "%LIB%" :RunJob
