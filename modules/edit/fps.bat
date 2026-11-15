@echo off
rem ============================================================
rem modules\edit\fps.bat
rem Изменение частоты кадров: пропуск/дублирование, смешивание или интерполяция движения.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Частота кадров"
echo  1. 24    2. 25    3. 30    4. 50    5. 60    6. Своё значение
echo  0. Назад
echo.
call "%LIB%" :AskChoice "Целевая частота"
set "FPS="
if "%CHOICE%"=="1" set "FPS=24"
if "%CHOICE%"=="2" set "FPS=25"
if "%CHOICE%"=="3" set "FPS=30"
if "%CHOICE%"=="4" set "FPS=50"
if "%CHOICE%"=="5" set "FPS=60"
if "%CHOICE%"=="6" call "%LIB%" :AskNum FPS "Кадров в секунду" 30
if "%CHOICE%"=="0" exit /b 0
if not defined FPS (call "%LIB%" :InvalidChoice & exit /b 0)

echo.
echo Метод:
echo  1. Пропуск / дублирование кадров (быстро)        [Enter]
echo  2. Смешивание соседних кадров (framerate)
echo  3. Интерполяция движения (minterpolate, очень медленно, плавно)
call "%LIB%" :AskChoice "Метод"
set "VIDEO_FILTER=fps=%FPS%"
if "%CHOICE%"=="2" set "VIDEO_FILTER=framerate=fps=%FPS%"
if "%CHOICE%"=="3" set "VIDEO_FILTER=minterpolate=fps=%FPS%:mi_mode=mci:mc_mode=aobmc:vsbmc=1"
set "OUTPUT_SUFFIX=%FPS%fps"
set "JOB_TITLE=Частота кадров %FPS%"
call "%TRANSCODE%"
