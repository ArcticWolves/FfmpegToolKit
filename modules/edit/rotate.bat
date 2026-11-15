@echo off
rem ============================================================
rem modules\edit\rotate.bat
rem Поворот и отражение видео (с перекодированием или флагом поворота без потерь).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Поворот / отражение"
echo  С перекодированием:
echo   1. 90 по часовой
echo   2. 90 против часовой
echo   3. 180
echo   4. Отразить по горизонтали (зеркало)
echo   5. Отразить по вертикали
echo.
echo  Без перекодирования (флаг поворота в файле, мгновенно):
echo   6. 90 по часовой
echo   7. 90 против часовой
echo   8. 180
echo   9. Сбросить поворот
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"

set "VIDEO_FILTER="
set "ROT="
if "%CHOICE%"=="1" set "VIDEO_FILTER=transpose=clock"
if "%CHOICE%"=="2" set "VIDEO_FILTER=transpose=cclock"
if "%CHOICE%"=="3" set "VIDEO_FILTER=hflip,vflip"
if "%CHOICE%"=="4" set "VIDEO_FILTER=hflip"
if "%CHOICE%"=="5" set "VIDEO_FILTER=vflip"
rem -display_rotation задаётся против часовой стрелки
if "%CHOICE%"=="6" set "ROT=-90"
if "%CHOICE%"=="7" set "ROT=90"
if "%CHOICE%"=="8" set "ROT=180"
if "%CHOICE%"=="9" set "ROT=0"
if "%CHOICE%"=="0" exit /b 0

if defined ROT (
    set "INPUT_OPTS=-display_rotation:v:0 %ROT%"
    set "ENC_FIXED_ARGS=-map 0 -c copy"
    set "OUTPUT_SUFFIX=rot"
    set "JOB_TITLE=Флаг поворота"
    call "%TRANSCODE%"
    exit /b 0
)
if not defined VIDEO_FILTER (call "%LIB%" :InvalidChoice & exit /b 0)
set "OUTPUT_SUFFIX=rotate"
set "JOB_TITLE=Поворот"
call "%TRANSCODE%"
