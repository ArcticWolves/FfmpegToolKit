@echo off
rem ============================================================
rem modules\edit\segment.bat
rem Нарезка файла на части заданной длины без перекодирования.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Нарезка на сегменты"
if defined IN_DURATION echo Длительность: !IN_DURATION! с
echo Резы выполняются по ключевым кадрам, поэтому длина частей
echo может немного отличаться от заданной.
echo.
call "%LIB%" :AskInt SEG "Длина сегмента, секунд" 60 1 86400

set "SEG_DIR=%OUTPUT_DIR%\%INPUT_NAME%_segments"
if not exist "%SEG_DIR%" mkdir "%SEG_DIR%"
set "OUTPUT_FILE=%SEG_DIR%"
set "FF_ARGS=-i "!INPUT_FILE!" -map 0 -c copy -f segment -segment_time %SEG% -reset_timestamps 1 "!SEG_DIR!\!INPUT_NAME!_%%03d.!INPUT_EXT!""

call "%LIB%" :Header "Нарезка на сегменты"
echo Части будут сохранены в папку:
echo   !SEG_DIR!
call "%LIB%" :RunJob
