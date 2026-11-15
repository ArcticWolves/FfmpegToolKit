@echo off
rem ============================================================
rem modules\tools\image_audio.bat
rem Видео из статичной картинки и аудиофайла (для YouTube, подкастов).
rem ============================================================

call "%LIB%" :Header "Картинка + аудио"
echo Сначала выберите КАРТИНКУ, затем АУДИО.
pause
set "INPUT_TITLE=Картинка (обложка)"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
set "IMG=%INPUT_FILE%"
set "INPUT_TITLE=Аудио"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
set "AUD=%INPUT_FILE%"

rem Основной вход - аудио (по нему имя файла), картинка - второй вход
set "EXTRA_INPUTS=-loop 1 -framerate 2 -i "!IMG!""
set "MAP_ARGS=-map 1:v -map 0:a"
set "VIDEO_FILTER=scale=trunc(iw/2)*2:trunc(ih/2)*2,format=yuv420p"
set "EXTRA_OUT_OPTS=-shortest -r 2"
set "OUTPUT_EXT=mp4"
set "OUTPUT_SUFFIX=video"
set "PREF_VIDEO=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "PREF_AUDIO=aac"
set "JOB_TITLE=Картинка + аудио"
call "%TRANSCODE%"
