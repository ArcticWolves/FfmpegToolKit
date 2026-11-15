@echo off
rem ============================================================
rem modules\tools\strip_metadata.bat
rem Удаление метаданных (теги, GPS, модель камеры, главы) без перекодирования.
rem ============================================================

call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
set "OUTPUT_EXT=%INPUT_EXT%"
set "OUTPUT_SUFFIX=clean"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -map 0 -map_metadata -1 -map_chapters -1 -c copy -fflags +bitexact "!OUTPUT_FILE!""
call "%LIB%" :Header "Удаление метаданных"
call "%LIB%" :RunJob
