@echo off
setlocal

rem ============================================================
rem FFprobe Wrapper Module
rem Единый интерфейс для анализа мультимедийных файлов.
rem Требует предварительного вызова config.bat.
rem ============================================================

if not defined FFPROBE (
    echo [ERROR] Переменная FFPROBE не определена.
    echo [ERROR] Сначала вызовите config.bat.
    exit /b 1
)

if "%~1"=="" goto :HELP

set "COMMAND=%~1"
set "INPUT=%~2"

if /I "%COMMAND%"=="help"          goto :HELP
if /I "%COMMAND%"=="info"          goto :FULL_INFO
if /I "%COMMAND%"=="format"        goto :FORMAT_NAME
if /I "%COMMAND%"=="duration"      goto :DURATION
if /I "%COMMAND%"=="bitrate"       goto :BITRATE
if /I "%COMMAND%"=="stream_count"  goto :STREAM_COUNT

if /I "%COMMAND%"=="codec_video"   goto :CODEC_VIDEO
if /I "%COMMAND%"=="codec_audio"   goto :CODEC_AUDIO
if /I "%COMMAND%"=="width"         goto :WIDTH
if /I "%COMMAND%"=="height"        goto :HEIGHT
if /I "%COMMAND%"=="resolution"    goto :RESOLUTION
if /I "%COMMAND%"=="fps"           goto :FPS

if /I "%COMMAND%"=="audio_channels" goto :AUDIO_CHANNELS
if /I "%COMMAND%"=="sample_rate"    goto :SAMPLE_RATE

if /I "%COMMAND%"=="has_audio"      goto :HAS_AUDIO
if /I "%COMMAND%"=="has_video"      goto :HAS_VIDEO
if /I "%COMMAND%"=="has_subtitles"  goto :HAS_SUBTITLES

if /I "%COMMAND%"=="interactive"    goto :INTERACTIVE

echo [ERROR] Неизвестная команда: %COMMAND%
goto :HELP


rem ============================================================
rem Проверка входного файла
rem ============================================================
:CHECK_INPUT
if "%INPUT%"=="" (
    echo [ERROR] Не указан входной файл.
    exit /b 1
)

if not exist "%INPUT%" (
    echo [ERROR] Файл не найден:
    echo         "%INPUT%"
    exit /b 1
)

exit /b 0


rem ============================================================
rem Универсальная подпрограмма для FFprobe
rem ============================================================
:RUN
call :CHECK_INPUT
if errorlevel 1 exit /b 1

"%FFPROBE%" -v error %* "%INPUT%"
exit /b %ERRORLEVEL%


rem ============================================================
rem Общая информация
rem ============================================================
:FULL_INFO
call :CHECK_INPUT || exit /b 1
"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%"
exit /b

:FORMAT_NAME
call :RUN -show_entries format^=format_name -of default^=nokey^=1:noprint_wrappers^=1

:DURATION
call :RUN -show_entries format^=duration -of default^=nokey^=1:noprint_wrappers^=1

:BITRATE
call :RUN -show_entries format^=bit_rate -of default^=nokey^=1:noprint_wrappers^=1

:STREAM_COUNT
call :RUN -show_entries format^=nb_streams -of default^=nokey^=1:noprint_wrappers^=1


rem ============================================================
rem Видео
rem ============================================================
:CODEC_VIDEO
call :RUN -select_streams v:0 -show_entries stream^=codec_name -of default^=nokey^=1:noprint_wrappers^=1

:WIDTH
call :RUN -select_streams v:0 -show_entries stream^=width -of default^=nokey^=1:noprint_wrappers^=1

:HEIGHT
call :RUN -select_streams v:0 -show_entries stream^=height -of default^=nokey^=1:noprint_wrappers^=1

:RESOLUTION
call :CHECK_INPUT || exit /b 1
for /f "tokens=1,2 delims=x" %%A in ('"%FFPROBE%" -v error -select_streams v:0 -show_entries stream^=width,height -of csv^=s^=x:p^=0 "%INPUT%"') do (
    echo %%Ax%%B
)
exit /b

:FPS
call :CHECK_INPUT || exit /b 1
for /f %%F in ('"%FFPROBE%" -v error -select_streams v:0 -show_entries stream^=avg_frame_rate -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"') do echo %%F
exit /b


rem ============================================================
rem Аудио
rem ============================================================
:CODEC_AUDIO
call :RUN -select_streams a:0 -show_entries stream^=codec_name -of default^=nokey^=1:noprint_wrappers^=1

:AUDIO_CHANNELS
call :RUN -select_streams a:0 -show_entries stream^=channels -of default^=nokey^=1:noprint_wrappers^=1

:SAMPLE_RATE
call :RUN -select_streams a:0 -show_entries stream^=sample_rate -of default^=nokey^=1:noprint_wrappers^=1


rem ============================================================
rem Наличие потоков
rem ============================================================
:HAS_AUDIO
call :CHECK_INPUT || exit /b 1
for /f %%A in ('"%FFPROBE%" -v error -select_streams a -show_entries stream^=index -of csv^=p^=0 "%INPUT%"') do (
    echo 1
    exit /b 0
)
echo 0
exit /b 0

:HAS_VIDEO
call :CHECK_INPUT || exit /b 1
for /f %%A in ('"%FFPROBE%" -v error -select_streams v -show_entries stream^=index -of csv^=p^=0 "%INPUT%"') do (
    echo 1
    exit /b 0
)
echo 0
exit /b 0

:HAS_SUBTITLES
call :CHECK_INPUT || exit /b 1
for /f %%A in ('"%FFPROBE%" -v error -select_streams s -show_entries stream^=index -of csv^=p^=0 "%INPUT%"') do (
    echo 1
    exit /b 0
)
echo 0
exit /b 0


rem ============================================================
rem Интерактивный режим
rem ============================================================
:INTERACTIVE
cls
echo ========================================
echo            FFprobe Analyzer
echo ========================================
echo.
set /p INPUT=Введите путь к файлу:

if not exist "%INPUT%" (
    echo.
    echo [ERROR] Файл не найден.
    pause
    exit /b 1
)

echo.
echo 1. Полная информация (JSON)
echo 2. Формат контейнера
echo 3. Видеокодек
echo 4. Аудиокодек
echo 5. Разрешение
echo 6. Длительность
echo 7. FPS
echo 8. Битрейт
echo 9. Проверить наличие субтитров
echo 0. Выход
echo.
set /p CHOICE=Выберите пункт:

echo.
if "%CHOICE%"=="1" call "%~f0" info "%INPUT%"
if "%CHOICE%"=="2" call "%~f0" format "%INPUT%"
if "%CHOICE%"=="3" call "%~f0" codec_video "%INPUT%"
if "%CHOICE%"=="4" call "%~f0" codec_audio "%INPUT%"
if "%CHOICE%"=="5" call "%~f0" resolution "%INPUT%"
if "%CHOICE%"=="6" call "%~f0" duration "%INPUT%"
if "%CHOICE%"=="7" call "%~f0" fps "%INPUT%"
if "%CHOICE%"=="8" call "%~f0" bitrate "%INPUT%"
if "%CHOICE%"=="9" call "%~f0" has_subtitles "%INPUT%"
if "%CHOICE%"=="0" exit /b 0

pause
exit /b


rem ============================================================
rem Справка
rem ============================================================
:HELP

echo.
echo Использование:
echo   call ffprobe.bat команда "файл"
echo.
echo Команды:
echo   info
echo   format
echo   duration
echo   bitrate
echo   stream_count
echo   codec_video
echo   codec_audio
echo   width
echo   height
echo   resolution
echo   fps
echo   audio_channels
echo   sample_rate
echo   has_audio
echo   has_video
echo   has_subtitles
echo   interactive
echo.
exit /b 1