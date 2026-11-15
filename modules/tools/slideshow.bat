@echo off
rem ============================================================
rem modules\tools\slideshow.bat
rem Слайд-шоу из всех изображений папки input (по имени файла).
rem ============================================================

call "%LIB%" :Header "Слайд-шоу"
set "LIST=%TEMP_DIR%\slideshow.txt"
type nul > "%LIST%"
set "N=0"
set "LAST="
call "%LIB%" :AskNum DUR "Секунд на один слайд" 3
for /f "delims=" %%F in ('dir /b /a-d /on "%INPUT_DIR%" 2^>nul') do (
    for %%X in (.png .jpg .jpeg .bmp .webp .tif .tiff) do (
        if /i "%%~xF"=="%%X" call :AddSlide "%INPUT_DIR%\%%F"
    )
)
if %N% LSS 1 (echo [ERROR] В папке input нет изображений. & pause & exit /b 0)
rem concat demuxer требует повторить последний файл без duration
>> "%LIST%" echo file '!LAST!'
echo Слайдов: %N%
call "%LIB%" :AskInt W "Ширина видео" 1920 160 7680
call "%LIB%" :AskInt H "Высота видео" 1080 120 4320

set "INPUT_FILE=%LIST%"
set "INPUT_OPTS=-f concat -safe 0"
set "OUTPUT_BASE=slideshow"
set "OUTPUT_EXT=mp4"
set "OUTPUT_SUFFIX=%W%x%H%"
set "VIDEO_FILTER=scale=%W%:%H%:force_original_aspect_ratio=decrease,pad=%W%:%H%:-1:-1:color=black,setsar=1,fps=30,format=yuv420p"
set "ENC_NO_AUDIO=1"
set "PREF_VIDEO=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "JOB_TITLE=Слайд-шоу"
call "%TRANSCODE%"
exit /b 0

:AddSlide
set /a N+=1
set "LAST=%~1"
set "LAST=!LAST:'='\''!"
>> "%LIST%" echo file '!LAST!'
>> "%LIST%" echo duration %DUR%
exit /b 0
