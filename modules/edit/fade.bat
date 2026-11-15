@echo off
rem ============================================================
rem modules\edit\fade.bat
rem Плавное появление и затухание видео и звука.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
if not defined IN_DURATION (
    echo [ERROR] Не удалось определить длительность файла.
    pause
    exit /b 1
)
call "%LIB%" :Header "Появление / затухание"
echo Длительность: !IN_DURATION! с
echo 0 = без эффекта.
echo.
call "%LIB%" :AskNum FIN "Появление, секунд" 1
call "%LIB%" :AskNum FOUT "Затухание, секунд" 1

call "%LIB%" :ToMilli DUR_MS "%IN_DURATION%"
call "%LIB%" :ToMilli FIN_MS "%FIN%"
call "%LIB%" :ToMilli FOUT_MS "%FOUT%"
set /a "ST_MS=DUR_MS-FOUT_MS"
if %ST_MS% LSS 0 set "ST_MS=0"
call "%LIB%" :FromMilli ST %ST_MS%

set "VF=" & set "AF="
if %FIN_MS% GTR 0 (
    set "VF=fade=t=in:st=0:d=%FIN%"
    set "AF=afade=t=in:st=0:d=%FIN%"
)
if %FOUT_MS% GTR 0 (
    if defined VF (set "VF=!VF!,") 
    if defined AF (set "AF=!AF!,")
    set "VF=!VF!fade=t=out:st=%ST%:d=%FOUT%"
    set "AF=!AF!afade=t=out:st=%ST%:d=%FOUT%"
)
if not defined VF (echo Нечего делать. & pause & exit /b 0)
if "%IN_HAS_VIDEO%"=="1" set "VIDEO_FILTER=%VF%"
if "%IN_HAS_AUDIO%"=="1" set "AUDIO_FILTER=%AF%"
set "OUTPUT_SUFFIX=fade"
set "JOB_TITLE=Появление / затухание"
call "%TRANSCODE%"
