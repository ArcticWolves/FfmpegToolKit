@echo off
rem ============================================================
rem modules\edit\resize.bat
rem Масштабирование с сохранением пропорций (чётные размеры для H.264/HEVC).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
set "FLAGS=lanczos"

:MENU
call "%LIB%" :Header "Масштабирование"
if defined IN_WIDTH echo Исходный размер: !IN_WIDTH!x!IN_HEIGHT!
echo Алгоритм: %FLAGS%
echo.
echo  По высоте (пропорции сохраняются):
echo   1. 480p    2. 720p    3. 1080p    4. 1440p    5. 2160p (4K)
echo.
echo   6. Своя ширина (высота по пропорциям)
echo   7. Своя высота (ширина по пропорциям)
echo   8. Точный размер (растянуть)
echo   9. Вписать в размер с полями (без искажений)
echo  10. В процентах
echo  11. Алгоритм масштабирования
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите режим"

set "SCALE="
if "%CHOICE%"=="1" set "SCALE=-2:480"
if "%CHOICE%"=="2" set "SCALE=-2:720"
if "%CHOICE%"=="3" set "SCALE=-2:1080"
if "%CHOICE%"=="4" set "SCALE=-2:1440"
if "%CHOICE%"=="5" set "SCALE=-2:2160"
if "%CHOICE%"=="6" (
    call "%LIB%" :AskInt W "Ширина" 1280 16 16384
    set "SCALE=!W!:-2"
)
if "%CHOICE%"=="7" (
    call "%LIB%" :AskInt H "Высота" 720 16 16384
    set "SCALE=-2:!H!"
)
if "%CHOICE%"=="8" (
    call "%LIB%" :AskInt W "Ширина" 1280 16 16384
    call "%LIB%" :AskInt H "Высота" 720 16 16384
    set "SCALE=!W!:!H!,setsar=1"
)
if "%CHOICE%"=="9" (
    call "%LIB%" :AskInt W "Ширина" 1920 16 16384
    call "%LIB%" :AskInt H "Высота" 1080 16 16384
    set "SCALE=!W!:!H!:force_original_aspect_ratio=decrease,pad=!W!:!H!:-1:-1:color=black,setsar=1"
)
if "%CHOICE%"=="10" (
    call "%LIB%" :AskInt P "Процент" 50 1 1000
    set "SCALE=trunc(iw*!P!/200)*2:trunc(ih*!P!/200)*2"
)
if "%CHOICE%"=="11" goto SELECT_FLAGS
if "%CHOICE%"=="0" exit /b 0
if not defined SCALE (call "%LIB%" :InvalidChoice & goto MENU)

rem Флаги алгоритма вставляются сразу после размеров scale=W:H
for /f "tokens=1* delims=," %%A in ("!SCALE!") do (
    set "VIDEO_FILTER=scale=%%A:flags=%FLAGS%"
    if not "%%B"=="" set "VIDEO_FILTER=!VIDEO_FILTER!,%%B"
)
set "OUTPUT_SUFFIX=resized"
set "JOB_TITLE=Масштабирование"
call "%TRANSCODE%"
exit /b 0

:SELECT_FLAGS
echo.
echo  bicubic  - по умолчанию FFmpeg
echo  bilinear - быстрее
echo  lanczos  - чётче, лучше для уменьшения
echo  spline   - высокое качество
echo  neighbor - без сглаживания (pixel art)
call "%LIB%" :AskPick FLAGS "Алгоритм" %FLAGS% "bicubic bilinear lanczos spline neighbor area"
goto MENU
