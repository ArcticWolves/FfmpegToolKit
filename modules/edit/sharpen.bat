@echo off
rem ============================================================
rem modules\edit\sharpen.bat
rem Повышение резкости (unsharp / cas).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Резкость"
echo   1. Лёгкая     2. Средняя     3. Сильная
echo   4. CAS (адаптивная, мягкий результат)
echo   5. Размытие (обратный эффект)
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
set "VIDEO_FILTER="
if "%CHOICE%"=="1" set "VIDEO_FILTER=unsharp=5:5:0.5:5:5:0"
if "%CHOICE%"=="2" set "VIDEO_FILTER=unsharp=5:5:1.0:5:5:0"
if "%CHOICE%"=="3" set "VIDEO_FILTER=unsharp=7:7:1.5:5:5:0"
if "%CHOICE%"=="4" (
    call "%LIB%" :AskNum S "Сила CAS, 0..1" 0.6
    set "VIDEO_FILTER=cas=strength=!S!"
)
if "%CHOICE%"=="5" (
    call "%LIB%" :AskNum S "Радиус размытия (sigma), 0.5..50" 5
    set "VIDEO_FILTER=gblur=sigma=!S!"
)
if "%CHOICE%"=="0" exit /b 0
if not defined VIDEO_FILTER (call "%LIB%" :InvalidChoice & exit /b 0)
set "OUTPUT_SUFFIX=sharp"
if "%CHOICE%"=="5" set "OUTPUT_SUFFIX=blur"
set "JOB_TITLE=Резкость"
call "%TRANSCODE%"
