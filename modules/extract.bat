@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\extract.bat
rem Раздел "Извлечение": потоки без перекодирования, кадры,
rem обложка, субтитры, главы и метаданные.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Извлечение"
echo   1. Аудиодорожка без перекодирования (расширение по кодеку)
echo   2. Видео без звука (без перекодирования)
echo   3. Субтитры в файл (.srt / .ass / .vtt)
echo   4. Кадры в изображения
echo   5. Обложка из аудиофайла
echo   6. Метаданные и главы в текстовый файл
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if "%CHOICE%"=="0" goto EXIT_MODULE
set "ACTION="
if "%CHOICE%"=="1" set "ACTION=AUDIO"
if "%CHOICE%"=="2" set "ACTION=VIDEO"
if "%CHOICE%"=="3" set "ACTION=SUBS"
if "%CHOICE%"=="4" set "ACTION=FRAMES"
if "%CHOICE%"=="5" set "ACTION=COVER"
if "%CHOICE%"=="6" set "ACTION=META"
if not defined ACTION (call "%LIB%" :InvalidChoice & goto MAIN_MENU)

setlocal
call "%SELECTORS_DIR%\select_input_file.bat"
if not errorlevel 1 (
    call "%LIB%" :ProbeInput
    call :%ACTION%
)
endlocal
goto MAIN_MENU


rem ------------------------------------------------------------
rem Аудио без перекодирования. Расширение выбирается по кодеку,
rem неизвестные кодеки сохраняются в .mka (Matroska audio).
rem ------------------------------------------------------------
:AUDIO
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 0)
call :AskStream a "аудиодорожки"
call "%LIB%" :Probe CODEC "-select_streams a:%STREAM% -show_entries stream=codec_name" "%INPUT_FILE%"
set "OUTPUT_EXT=mka"
if /i "%CODEC%"=="aac"    set "OUTPUT_EXT=m4a"
if /i "%CODEC%"=="alac"   set "OUTPUT_EXT=m4a"
if /i "%CODEC%"=="mp3"    set "OUTPUT_EXT=mp3"
if /i "%CODEC%"=="opus"   set "OUTPUT_EXT=opus"
if /i "%CODEC%"=="vorbis" set "OUTPUT_EXT=ogg"
if /i "%CODEC%"=="flac"   set "OUTPUT_EXT=flac"
if /i "%CODEC%"=="ac3"    set "OUTPUT_EXT=ac3"
if /i "%CODEC%"=="eac3"   set "OUTPUT_EXT=eac3"
if /i "%CODEC%"=="dts"    set "OUTPUT_EXT=dts"
if /i "%CODEC%"=="wavpack" set "OUTPUT_EXT=wv"
if /i "%CODEC:~0,4%"=="pcm_" set "OUTPUT_EXT=wav"
echo Кодек: %CODEC%  -^>  .%OUTPUT_EXT%
set "OUTPUT_SUFFIX=audio"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -map 0:a:%STREAM% -vn -c copy "!OUTPUT_FILE!""
call "%LIB%" :RunJob
exit /b 0


:VIDEO
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] В файле нет видео. & pause & exit /b 0)
set "OUTPUT_EXT=%INPUT_EXT%"
set "OUTPUT_SUFFIX=video"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -map 0:v -map 0:s? -an -c copy "!OUTPUT_FILE!""
call "%LIB%" :RunJob
exit /b 0


rem ------------------------------------------------------------
rem Субтитры. Текстовые форматы конвертируются, графические
rem (PGS, DVD) сохраняются как есть в .mks.
rem ------------------------------------------------------------
:SUBS
if not "%IN_HAS_SUBS%"=="1" (echo [ERROR] В файле нет субтитров. & pause & exit /b 0)
call :AskStream s "субтитров"
call "%LIB%" :Probe CODEC "-select_streams s:%STREAM% -show_entries stream=codec_name" "%INPUT_FILE%"
set "SUB_CODEC=copy"
set "OUTPUT_EXT=mks"
if /i "%CODEC%"=="subrip"   (set "OUTPUT_EXT=srt")
if /i "%CODEC%"=="mov_text" (set "OUTPUT_EXT=srt" & set "SUB_CODEC=srt")
if /i "%CODEC%"=="ass"      (set "OUTPUT_EXT=ass")
if /i "%CODEC%"=="ssa"      (set "OUTPUT_EXT=ass" & set "SUB_CODEC=ass")
if /i "%CODEC%"=="webvtt"   (set "OUTPUT_EXT=vtt")
if /i "%OUTPUT_EXT%"=="srt" (
    call "%LIB%" :AskPick FMT "Формат: srt, ass, vtt" srt "srt ass vtt"
    set "OUTPUT_EXT=!FMT!"
    set "SUB_CODEC=!FMT!"
    if /i "!FMT!"=="vtt" set "SUB_CODEC=webvtt"
)
echo Кодек: %CODEC%  -^>  .%OUTPUT_EXT%
set "OUTPUT_SUFFIX=subs"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -map 0:s:%STREAM% -c:s %SUB_CODEC% "!OUTPUT_FILE!""
call "%LIB%" :RunJob
exit /b 0


rem ------------------------------------------------------------
rem Кадры
rem ------------------------------------------------------------
:FRAMES
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] В файле нет видео. & pause & exit /b 0)
call "%LIB%" :Header "Кадры в изображения"
echo   1. Каждый N-й секунды          [Enter]
echo   2. Все кадры
echo   3. Только ключевые кадры (I-frames)
echo   4. При смене сцены
echo   5. Заданное количество кадров равномерно по всему видео
call "%LIB%" :AskChoice "Режим"
set "VF=" & set "IN_OPTS=" & set "OUT_OPTS="
if not defined CHOICE set "CHOICE=1"
if "%CHOICE%"=="1" (
    call "%LIB%" :AskNum SEC "Интервал, секунд" 1
    set "VF=fps=1/!SEC!"
)
if "%CHOICE%"=="3" (
    set "IN_OPTS=-skip_frame nokey"
    set "OUT_OPTS=-fps_mode vfr"
)
if "%CHOICE%"=="4" (
    call "%LIB%" :AskNum TH "Чувствительность 0.1-0.9, меньше = больше кадров" 0.3
    set "VF=select='gt(scene,!TH!)'"
    set "OUT_OPTS=-fps_mode vfr"
)
if "%CHOICE%"=="5" (
    if not defined IN_DURATION (echo [ERROR] Длительность неизвестна. & pause & exit /b 0)
    call "%LIB%" :AskInt CNT "Количество кадров" 10 1 10000
    set "VF=fps=!CNT!/!IN_DURATION!"
)
call "%LIB%" :AskPick FMT "Формат: png, jpg, webp" jpg "png jpg webp"
set "Q="
if /i "%FMT%"=="jpg" set "Q=-q:v 2"
if /i "%FMT%"=="webp" set "Q=-quality 90"

set "FR_DIR=%OUTPUT_DIR%\%INPUT_NAME%_frames"
if not exist "%FR_DIR%" mkdir "%FR_DIR%"
set "OUTPUT_FILE=%FR_DIR%"
set "FF_ARGS=%IN_OPTS% -i "!INPUT_FILE!""
if defined VF set "FF_ARGS=!FF_ARGS! -vf "!VF!""
set "FF_ARGS=!FF_ARGS! %OUT_OPTS% %Q% "!FR_DIR!\frame_%%05d.%FMT%""
echo.
echo Кадры будут сохранены в: !FR_DIR!
call "%LIB%" :RunJob
exit /b 0


:COVER
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] В файле нет обложки. & pause & exit /b 0)
set "OUTPUT_EXT=jpg"
if /i "%IN_VCODEC%"=="png" set "OUTPUT_EXT=png"
set "OUTPUT_SUFFIX=cover"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "C_ARGS=-c:v copy"
if /i not "%IN_VCODEC%"=="mjpeg" if /i not "%IN_VCODEC%"=="png" set "C_ARGS=-q:v 2"
set "FF_ARGS=-i "!INPUT_FILE!" -map 0:v:0 -frames:v 1 %C_ARGS% -update 1 "!OUTPUT_FILE!""
call "%LIB%" :RunJob
exit /b 0


:META
set "OUTPUT_EXT=txt"
set "OUTPUT_SUFFIX=metadata"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0
set "FF_ARGS=-i "!INPUT_FILE!" -f ffmetadata "!OUTPUT_FILE!""
call "%LIB%" :RunJob
exit /b 0


rem ------------------------------------------------------------
rem :AskStream тип "описание" -> STREAM (номер среди потоков типа)
rem ------------------------------------------------------------
:AskStream
set "STREAM=0"
"%FFPROBE%" -v error -select_streams %1 -show_entries stream=index,codec_name:stream_tags=language,title -of csv=p=0 "%INPUT_FILE%" > "%TEMP_DIR%\streams.tmp" 2>nul
set "SCOUNT=0"
for /f "usebackq delims=" %%L in ("%TEMP_DIR%\streams.tmp") do set /a SCOUNT+=1
if %SCOUNT% LEQ 1 exit /b 0
echo.
echo Дорожки %~2 (номер: индекс,кодек,язык,название):
set "I=0"
for /f "usebackq delims=" %%L in ("%TEMP_DIR%\streams.tmp") do (
    echo   !I!: %%L
    set /a I+=1
)
set /a "MAXS=SCOUNT-1"
call "%LIB%" :AskInt STREAM "Номер дорожки" 0 0 %MAXS%
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
