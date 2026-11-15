@echo off
rem ============================================================
rem modules\edit\reverse.bat
rem Воспроизведение задом наперёд (reverse / areverse).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Реверс"
echo Фильтры reverse/areverse держат весь клип в памяти.
echo Подходит для коротких фрагментов (до 1-2 минут). Длинное
echo видео сначала обрежьте.
if defined IN_DURATION echo Длительность файла: !IN_DURATION! с
echo.
call "%LIB%" :AskYN "Продолжить?" Y
if errorlevel 1 exit /b 0
if "%IN_HAS_VIDEO%"=="1" set "VIDEO_FILTER=reverse"
if "%IN_HAS_AUDIO%"=="1" set "AUDIO_FILTER=areverse"
set "OUTPUT_SUFFIX=reverse"
set "JOB_TITLE=Реверс"
call "%TRANSCODE%"
