@echo off
rem ============================================================
rem modules\edit\audio_remove.bat
rem Удалить все аудиодорожки без перекодирования видео.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Удаление аудио"
set "ENC_FIXED_ARGS=-map 0 -map -0:a -c copy"
set "OUTPUT_SUFFIX=noaudio"
set "JOB_TITLE=Удаление аудио"
call "%TRANSCODE%"
