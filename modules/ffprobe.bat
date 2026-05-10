:: Этот модуль создаёт единый интерфейс для получения информации о мультимедийных файлах.
@echo off
exit /b 0


:HAS_AUDIO
call :CHECK_INPUT
if errorlevel 1 exit /b 1
for /f %%A in ('"%FFPROBE%" -v error -select_streams a -show_entries stream^=index -of csv^=p^=0 "%INPUT%"') do (
    echo 1
    exit /b 0
)
echo 0
exit /b 0


:HAS_VIDEO
call :CHECK_INPUT
if errorlevel 1 exit /b 1
for /f %%A in ('"%FFPROBE%" -v error -select_streams v -show_entries stream^=index -of csv^=p^=0 "%INPUT%"') do (
    echo 1
    exit /b 0
)
echo 0
exit /b 0


:STREAM_COUNT
call :CHECK_INPUT
if errorlevel 1 exit /b 1
"%FFPROBE%" -v error -show_entries format^=nb_streams -of csv^=p^=0 "%INPUT%"
exit /b


:FORMAT_NAME
call :CHECK_INPUT
if errorlevel 1 exit /b 1
"%FFPROBE%" -v error -show_entries format^=format_name -of csv^=p^=0 "%INPUT%"
exit /b


:FULL_INFO
call :CHECK_INPUT
if errorlevel 1 exit /b 1
"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%"
exit /b


:HELP
echo Использование:
echo.
echo   ffprobe.bat команда "файл"
echo.
echo Доступные команды:
echo   codec_audio
echo   codec_video
echo   duration
echo   width
echo   height
echo   resolution
echo   fps
echo   bitrate
echo   audio_channels
echo   sample_rate
echo   has_subtitles
echo   has_audio
echo   has_video
echo   stream_count
echo   format
echo   info
exit /b 1