@echo off
rem ============================================================
rem modules\tools\waveform.bat
rem Изображение волновой формы аудио (showwavespic).
rem ============================================================

call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 0)
call "%LIB%" :Header "Волновая форма"
call "%LIB%" :AskInt W "Ширина" 1920 200 8000
call "%LIB%" :AskInt H "Высота" 400 50 4000
call "%LIB%" :Ask COLOR "Цвет (имя или 0xRRGGBB)" "0x3399ff"
call "%LIB%" :AskYN "Каналы раздельно?" N
if errorlevel 1 (set "SPLIT=0") else (set "SPLIT=1")
set "OUTPUT_EXT=png"
set "OUTPUT_SUFFIX=wave"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -filter_complex "showwavespic=s=%W%x%H%:split_channels=%SPLIT%:colors=%COLOR%" -frames:v 1 -update 1 "!OUTPUT_FILE!""
call "%LIB%" :RunJob
