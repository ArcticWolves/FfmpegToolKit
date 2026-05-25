@echo off
setlocal

:MENU
cls
echo ========================================
echo              PRESETS MENU
echo ========================================
echo.
echo 1. MP3 320 kbps
echo 2. WAV PCM 16-bit
echo 3. FLAC Lossless
echo 4. MP4 H.264 High Quality
echo 5. MP4 AV1 High Quality
echo 6. WebM VP9
echo 7. GIF Animation
echo 0. Cancel
echo.

set /p CHOICE=Select preset:

if "%CHOICE%"=="1" goto PRESET_MP3
if "%CHOICE%"=="2" goto PRESET_WAV
if "%CHOICE%"=="3" goto PRESET_FLAC
if "%CHOICE%"=="4" goto PRESET_H264
if "%CHOICE%"=="5" goto PRESET_AV1
if "%CHOICE%"=="6" goto PRESET_VP9
if "%CHOICE%"=="7" goto PRESET_GIF
if "%CHOICE%"=="0" exit /b 1

goto MENU

:PRESET_MP3
set "PRESET_NAME=MP3 320 kbps"
set "PRESET_EXT=mp3"
set "PRESET_ARGS=-vn -c:a libmp3lame -b:a 320k"
goto RETURN

:PRESET_WAV
set "PRESET_NAME=WAV PCM 16-bit"
set "PRESET_EXT=wav"
set "PRESET_ARGS=-vn -c:a pcm_s16le"
goto RETURN

:PRESET_FLAC
set "PRESET_NAME=FLAC Lossless"
set "PRESET_EXT=flac"
set "PRESET_ARGS=-vn -c:a flac"
goto RETURN

:PRESET_H264
set "PRESET_NAME=MP4 H.264 High Quality"
set "PRESET_EXT=mp4"
set "PRESET_ARGS=-c:v libopenh264 -b:v 5M -c:a aac -b:a 192k"
goto RETURN

:PRESET_AV1
set "PRESET_NAME=MP4 AV1 High Quality"
set "PRESET_EXT=mp4"
set "PRESET_ARGS=-c:v libsvtav1 -preset 4 -crf 28 -c:a aac -b:a 192k"
goto RETURN

:PRESET_VP9
set "PRESET_NAME=WebM VP9"
set "PRESET_EXT=webm"
set "PRESET_ARGS=-c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -b:a 128k"
goto RETURN

:PRESET_GIF
set "PRESET_NAME=GIF Animation"
set "PRESET_EXT=gif"
set "PRESET_ARGS=-vf fps=15,scale=640:-1:flags=lanczos"
goto RETURN

:RETURN
endlocal & (
    set "PRESET_NAME=%PRESET_NAME%"
    set "PRESET_EXT=%PRESET_EXT%"
    set "PRESET_ARGS=%PRESET_ARGS%"
)
exit /b 0
