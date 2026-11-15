@echo off
rem ============================================================
rem modules\tools\contact_sheet.bat
rem Контакт-лист: сетка равномерно взятых кадров в одном изображении.
rem ============================================================

call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
call "%LIB%" :ProbeInput
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] В файле нет видео. & pause & exit /b 0)
if not defined IN_DURATION (echo [ERROR] Длительность неизвестна. & pause & exit /b 0)
call "%LIB%" :Header "Контакт-лист"
call "%LIB%" :AskInt COLS "Колонок" 4 1 20
call "%LIB%" :AskInt ROWS "Строк" 4 1 20
call "%LIB%" :AskInt TW "Ширина одного кадра, пикселей" 320 64 1920
set /a "CNT=COLS*ROWS"
rem fps = кадров / длительность: кадры берутся равномерно по всему видео
set "VF=fps=%CNT%/%IN_DURATION%,scale=%TW%:-2:flags=lanczos,tile=%COLS%x%ROWS%:padding=4:margin=4"
set "OUTPUT_EXT=jpg"
set "OUTPUT_SUFFIX=sheet"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -vf "!VF!" -frames:v 1 -q:v 2 -update 1 "!OUTPUT_FILE!""
call "%LIB%" :RunJob
