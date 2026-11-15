@echo off
rem ============================================================
rem modules\edit\loudnorm.bat
rem Нормализация громкости по EBU R128 (loudnorm), один или два прохода.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 1)
call "%LIB%" :Header "Нормализация громкости"
echo Целевая громкость:
echo   1. -14 LUFS  YouTube, Spotify, соцсети   [Enter]
echo   2. -16 LUFS  подкасты, Apple Music
echo   3. -23 LUFS  телевидение (EBU R128)
echo   4. Своё значение
call "%LIB%" :AskChoice "Вариант"
set "I=-14"
if "%CHOICE%"=="2" set "I=-16"
if "%CHOICE%"=="3" set "I=-23"
if "%CHOICE%"=="4" call "%LIB%" :AskNum I "Целевая громкость, LUFS (-70..-5)" -16
set "TP=-1.5"
set "LRA=11"

echo.
echo  1. Точно, два прохода (сначала измерение)   [Enter]
echo  2. Быстро, один проход
call "%LIB%" :AskChoice "Режим"
set "BASE=loudnorm=I=%I%:TP=%TP%:LRA=%LRA%"
if "%CHOICE%"=="2" (
    set "AUDIO_FILTER=!BASE!,aresample=48000"
    goto RUN
)

rem ---- Проход 1: измерение, результат в JSON (stderr) ----
set "MEASURE=%TEMP_DIR%\loudnorm.txt"
echo.
echo [INFO] Проход 1: измерение громкости...
"%FFMPEG%" -hide_banner -nostats -i "%INPUT_FILE%" -map 0:a:0 -af "%BASE%:print_format=json" -f null - 2> "%MEASURE%"
set "M_I=" & set "M_TP=" & set "M_LRA=" & set "M_TH=" & set "M_OFF="
for /f "usebackq tokens=1,2 delims=:," %%A in ("%MEASURE%") do (
    set "_k=%%A"
    set "_v=%%B"
    set "_v=!_v: =!"
    set "_v=!_v:"=!"
    if not "!_k:input_i=!"=="!_k!" set "M_I=!_v!"
    if not "!_k:input_tp=!"=="!_k!" set "M_TP=!_v!"
    if not "!_k:input_lra=!"=="!_k!" set "M_LRA=!_v!"
    if not "!_k:input_thresh=!"=="!_k!" set "M_TH=!_v!"
    if not "!_k:target_offset=!"=="!_k!" set "M_OFF=!_v!"
)
if not defined M_OFF (
    echo [WARN] Не удалось измерить громкость - используется один проход.
    set "AUDIO_FILTER=!BASE!,aresample=48000"
    goto RUN
)
echo        Сейчас: !M_I! LUFS, пик !M_TP! dBTP
set "AUDIO_FILTER=!BASE!:measured_I=!M_I!:measured_TP=!M_TP!:measured_LRA=!M_LRA!:measured_thresh=!M_TH!:offset=!M_OFF!:linear=true,aresample=48000"
pause

:RUN
set "OUTPUT_SUFFIX=loudnorm"
set "JOB_TITLE=Нормализация громкости"
call "%TRANSCODE%"
