@echo off
rem ============================================================
rem modules\tools\remux.bat
rem Смена контейнера без перекодирования (потоки копируются как есть).
rem ============================================================

call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
call "%LIB%" :Header "Ремукс"
echo Файл: !INPUT_FILE!
echo Потоки копируются без потерь, меняется только контейнер.
echo Не каждый контейнер принимает любые кодеки: например, в MP4
echo нельзя положить субтитры ASS и звук Vorbis.
echo.
call "%LIB%" :AskPick OUTPUT_EXT "Новый контейнер: mp4, mkv, mov, webm, ts, avi" mkv "mp4 mkv mov webm ts avi"
if /i "%OUTPUT_EXT%"=="%INPUT_EXT%" (echo [ERROR] Контейнер уже %INPUT_EXT%. & pause & exit /b 0)
set "SUB=-c:s copy"
if /i "%OUTPUT_EXT%"=="mp4" set "SUB=-c:s mov_text"
if /i "%OUTPUT_EXT%"=="mov" set "SUB=-c:s mov_text"
if /i "%OUTPUT_EXT%"=="webm" set "SUB=-c:s webvtt"
set "MOV="
if /i "%OUTPUT_EXT%"=="mp4" set "MOV=-movflags +faststart"
if /i "%OUTPUT_EXT%"=="mov" set "MOV=-movflags +faststart"
set "OUTPUT_SUFFIX=remux"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -map 0 -c copy %SUB% %MOV% "!OUTPUT_FILE!""
call "%LIB%" :RunJob
if errorlevel 1 (
    echo Если ошибка про несовместимый поток - попробуйте MKV:
    echo он принимает практически любые кодеки.
    pause
)
