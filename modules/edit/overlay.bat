@echo off
rem ============================================================
rem modules\edit\overlay.bat
rem Водяной знак: картинка (PNG с прозрачностью), GIF или видео поверх основного видео.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] Во входном файле нет видео. & pause & exit /b 1)

call "%LIB%" :Header "Водяной знак"
call "%LIB%" :AskFile WM "Файл водяного знака (png, jpg, gif, mp4...)"
if errorlevel 1 exit /b 0

echo.
echo Позиция:
echo   1. Слева сверху     2. Справа сверху
echo   3. Слева снизу      4. Справа снизу   [Enter]
echo   5. По центру        6. Свои координаты
call "%LIB%" :AskChoice "Позиция"
if not defined CHOICE set "CHOICE=4"
call "%LIB%" :AskInt M "Отступ от края, пикселей" 20 0 2000

set "X=main_w-overlay_w-%M%" & set "Y=main_h-overlay_h-%M%"
if "%CHOICE%"=="1" (set "X=%M%" & set "Y=%M%")
if "%CHOICE%"=="2" (set "X=main_w-overlay_w-%M%" & set "Y=%M%")
if "%CHOICE%"=="3" (set "X=%M%" & set "Y=main_h-overlay_h-%M%")
if "%CHOICE%"=="5" (set "X=(main_w-overlay_w)/2" & set "Y=(main_h-overlay_h)/2")
if "%CHOICE%"=="6" (
    call "%LIB%" :AskInt X "X" 20 0 16384
    call "%LIB%" :AskInt Y "Y" 20 0 16384
)

call "%LIB%" :AskInt PCT "Ширина знака, процентов от ширины видео (0 = как есть)" 15 0 100
call "%LIB%" :AskNum OPACITY "Непрозрачность, 0.0-1.0" 0.8
call "%LIB%" :AskTime T_START "Показывать с (секунды, Enter = всё время)" ""
set "T_END="
if defined T_START call "%LIB%" :AskTime T_END "Показывать до (секунды)" ""

set "WM_SCALE="
if %PCT% GTR 0 if defined IN_WIDTH (
    set /a "WM_W=IN_WIDTH*PCT/100"
    set "WM_SCALE=scale=!WM_W!:-1,"
)
set "ENABLE="
if defined T_END set "ENABLE=:enable='between(t,%T_START%,%T_END%)'"

rem Картинка зацикливается как кадр (-loop 1), видео/GIF - как поток
set "LOOP=-stream_loop -1"
for %%X in (.png .jpg .jpeg .bmp .webp .tif .tiff) do (
    for %%F in ("%WM%") do if /i "%%~xF"=="%%X" set "LOOP=-loop 1"
)

set "EXTRA_INPUTS=!LOOP! -i "!WM!""
set "FILTER_COMPLEX=[1:v]!WM_SCALE!format=rgba,colorchannelmixer=aa=%OPACITY%[wm];[0:v][wm]overlay=!X!:!Y!:shortest=1!ENABLE![v]"
set "MAP_ARGS=-map "[v]" -map 0:a?"
set "ENC_VIDEO_NO_COPY=1"
set "OUTPUT_SUFFIX=watermark"
set "JOB_TITLE=Водяной знак"
call "%TRANSCODE%"
