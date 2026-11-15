@echo off
rem ============================================================
rem modules\tools\spectrum.bat
rem Спектрограмма аудио (showspectrumpic).
rem ============================================================

call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 0)
call "%LIB%" :Header "Спектрограмма"
call "%LIB%" :AskInt W "Ширина" 1920 200 8000
call "%LIB%" :AskInt H "Высота" 1080 100 4000
call "%LIB%" :AskPick SCALE "Шкала: log (речь, музыка) или lin" log "log lin sqrt cbrt"
set "OUTPUT_EXT=png"
set "OUTPUT_SUFFIX=spectrum"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -lavfi "showspectrumpic=s=%W%x%H%:legend=1:scale=%SCALE%" -frames:v 1 -update 1 "!OUTPUT_FILE!""
call "%LIB%" :RunJob
