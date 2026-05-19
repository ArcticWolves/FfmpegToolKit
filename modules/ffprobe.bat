@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem Enhanced FFprobe module for FFmpeg ToolKit.
rem See chat response for usage examples.

if not defined CONFIG_LOADED (
    echo [ERROR] Config not loaded.
    exit /b 1
)

if "%~1"=="" goto INTERACTIVE

set "COMMAND=%~1"
set "INPUT=%~2"

if /I "%COMMAND%"=="help" goto HELP
if /I "%COMMAND%"=="interactive" goto INTERACTIVE
if /I "%COMMAND%"=="report" goto REPORT
if /I "%COMMAND%"=="info" goto FULL_INFO
if /I "%COMMAND%"=="json_to_file" goto JSON_TO_FILE
if /I "%COMMAND%"=="codec_video" goto CODEC_VIDEO
if /I "%COMMAND%"=="codec_audio" goto CODEC_AUDIO
if /I "%COMMAND%"=="resolution" goto RESOLUTION
if /I "%COMMAND%"=="duration" goto DURATION
if /I "%COMMAND%"=="fps" goto FPS
if /I "%COMMAND%"=="pixel_format" goto PIXEL_FORMAT
if /I "%COMMAND%"=="frame_count" goto FRAME_COUNT
if /I "%COMMAND%"=="rotation" goto ROTATION
if /I "%COMMAND%"=="language_audio" goto LANGUAGE_AUDIO
if /I "%COMMAND%"=="compare" goto COMPARE
goto HELP

:CHECK_INPUT
if "%INPUT%"=="" exit /b 1
if not exist "%INPUT%" exit /b 1
exit /b 0

:RUN
call :CHECK_INPUT || exit /b 1
"%FFPROBE%" %FFPROBE_GLOBAL_OPTIONS% %* "%INPUT%"
exit /b %ERRORLEVEL%

:FULL_INFO
"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%"
exit /b 0

:DURATION
call :RUN -show_entries format^=duration -of default^=nokey^=1:noprint_wrappers^=1

:CODEC_VIDEO
call :RUN -select_streams v:0 -show_entries stream^=codec_name -of default^=nokey^=1:noprint_wrappers^=1

:CODEC_AUDIO
call :RUN -select_streams a:0 -show_entries stream^=codec_name -of default^=nokey^=1:noprint_wrappers^=1

:RESOLUTION
call :RUN -select_streams v:0 -show_entries stream^=width,height -of csv^=s^=x:p^=0

:FPS
call :RUN -select_streams v:0 -show_entries stream^=avg_frame_rate -of default^=nokey^=1:noprint_wrappers^=1

:PIXEL_FORMAT
call :RUN -select_streams v:0 -show_entries stream^=pix_fmt -of default^=nokey^=1:noprint_wrappers^=1

:FRAME_COUNT
call :RUN -count_frames -select_streams v:0 -show_entries stream^=nb_read_frames -of default^=nokey^=1:noprint_wrappers^=1

:ROTATION
call :RUN -select_streams v:0 -show_entries stream_tags^=rotate -of default^=nokey^=1:noprint_wrappers^=1

:LANGUAGE_AUDIO
call :RUN -select_streams a:0 -show_entries stream_tags^=language -of default^=nokey^=1:noprint_wrappers^=1

:JSON_TO_FILE
call :CHECK_INPUT || exit /b 1
for %%F in ("%INPUT%") do set "REPORT_FILE=%LOG_DIR%\%%~nF_ffprobe.json"
"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%" > "%REPORT_FILE%"
echo %REPORT_FILE%
exit /b 0

:REPORT
echo File: %INPUT%
echo Format:
call :RUN -show_entries format^=format_name -of default^=nokey^=1:noprint_wrappers^=1
echo Duration:
call "%~f0" duration "%INPUT%"
echo Video Codec:
call "%~f0" codec_video "%INPUT%"
echo Audio Codec:
call "%~f0" codec_audio "%INPUT%"
echo Resolution:
call "%~f0" resolution "%INPUT%"
echo FPS:
call "%~f0" fps "%INPUT%"
exit /b 0

:COMPARE
set "INPUT2=%~3"
if "%INPUT2%"=="" exit /b 1
echo ===== FILE 1 =====
call "%~f0" report "%INPUT%"
echo.
echo ===== FILE 2 =====
call "%~f0" report "%INPUT2%"
exit /b 0

:INTERACTIVE
set /p "INPUT=Введите путь к файлу: "
call "%~f0" report "%INPUT%"
pause
exit /b 0

:HELP
echo call ffprobe.bat report "video.mp4"
echo call ffprobe.bat codec_video "video.mp4"
echo call ffprobe.bat pixel_format "video.mp4"
exit /b 0
