@echo off
rem ============================================================
rem modules\edit\trim.bat
rem Обрезка по времени (быстро без перекодирования или точно).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Обрезка"
echo Файл: !INPUT_FILE!
if defined IN_DURATION echo Длительность: !IN_DURATION! с
echo.
echo Время: 00:01:30, 00:01:30.500 или в секундах (90).
call "%LIB%" :AskTime START "Начало" 0
call "%LIB%" :AskTime END "Конец (Enter = до конца файла)" ""
echo.
echo  1. Быстро, без перекодирования (рез по ближайшему ключевому кадру)
echo  2. Точно до кадра, с перекодированием
call "%LIB%" :AskChoice "Режим [Enter = 1]"

set "INPUT_OPTS=-ss %START%"
if defined END set "INPUT_OPTS=!INPUT_OPTS! -to %END%"
set "OUTPUT_SUFFIX=trim"
set "JOB_TITLE=Обрезка"
if "%CHOICE%"=="2" (
    set "ENC_VIDEO_NO_COPY=1"
    set "ENC_AUDIO_NO_COPY=1"
) else (
    set "ENC_FIXED_ARGS=-map 0 -c copy -avoid_negative_ts make_zero"
)
call "%TRANSCODE%"
