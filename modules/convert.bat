@echo off
setlocal EnableDelayedExpansion

:MENU
cls
echo ========================================
echo              Конвертация
echo ========================================
echo.
echo Поддерживаемые операции:
echo.
echo ---------------- Видео -----------------
echo 1.  MP4  (H.264 + AAC)      -^> Максимальная совместимость
echo 2.  MP4  (H.265 + AAC)      -^> Лучшее сжатие
echo 3.  WebM (VP9 + Opus)       -^> Открытый веб-формат
echo 4.  OGV  (Theora + Vorbis)  -^> Open Source формат
echo 9.  MP4  (AV1 + AAC)        -^> Современный формат
echo 10. MKV  (H.264 + Opus)     -^> Универсальный контейнер
echo 11. MKV  (H.265 + Opus)     -^> Архивное хранение
echo 12. MKV  (AV1 + Opus)       -^> Максимальное сжатие
echo 13. MOV  (ProRes + PCM)     -^> Монтажный формат
echo 14. AVI  (Xvid + MP3)       -^> Legacy формат
echo 15. GIF                     -^> Анимированный GIF
echo.
echo ---------------- Аудио -----------------
echo 5.  MP3                     -^> Максимальная совместимость
echo 6.  WAV                     -^> Без сжатия
echo 7.  FLAC                    -^> Lossless сжатие
echo 8.  Opus                    -^> Современное сжатие
echo 16. OGG Vorbis              -^> Открытый формат
echo 17. AAC (M4A)               -^> Формат Apple
echo 18. ALAC (M4A)              -^> Lossless Apple
echo 19. AIFF                    -^> Профессиональный PCM
echo 20. WavPack                 -^> Lossless
echo 21. AC3                     -^> Dolby Digital
echo 22. E-AC3                   -^> Dolby Digital Plus
echo.
echo --------------- Изображения ------------
echo 23. PNG
echo 24. JPEG
echo 25. WebP
echo 26. AVIF
echo 27. TIFF
echo 28. BMP
echo 29. TGA
echo.
echo 0. Назад
echo.

set /p CHOICE=Выберите пункт:

if "%CHOICE%"=="1" goto TO_MP4_H264
if "%CHOICE%"=="2" goto TO_MP4_H265
if "%CHOICE%"=="3" goto TO_WEBM
if "%CHOICE%"=="4" goto TO_OGV
if "%CHOICE%"=="5" goto TO_MP3
if "%CHOICE%"=="6" goto TO_WAV
if "%CHOICE%"=="7" goto TO_FLAC
if "%CHOICE%"=="8" goto TO_OPUS
if "%CHOICE%"=="9" goto TO_MP4_AV1
if "%CHOICE%"=="10" goto TO_MKV_H264
if "%CHOICE%"=="11" goto TO_MKV_H265
if "%CHOICE%"=="12" goto TO_MKV_AV1
if "%CHOICE%"=="13" goto TO_MOV_PRORES
if "%CHOICE%"=="14" goto TO_AVI_XVID
if "%CHOICE%"=="15" goto TO_GIF
if "%CHOICE%"=="16" goto TO_OGG
if "%CHOICE%"=="17" goto TO_AAC
if "%CHOICE%"=="18" goto TO_ALAC
if "%CHOICE%"=="19" goto TO_AIFF
if "%CHOICE%"=="20" goto TO_WAVPACK
if "%CHOICE%"=="21" goto TO_AC3
if "%CHOICE%"=="22" goto TO_EAC3
if "%CHOICE%"=="23" goto TO_PNG
if "%CHOICE%"=="24" goto TO_JPEG
if "%CHOICE%"=="25" goto TO_WEBP
if "%CHOICE%"=="26" goto TO_AVIF
if "%CHOICE%"=="27" goto TO_TIFF
if "%CHOICE%"=="28" goto TO_BMP
if "%CHOICE%"=="29" goto TO_TGA
if "%CHOICE%"=="0" exit /b

goto MENU


:ASK_INPUT
set "BATCH_MODE=0"
set "INPUT="
set "OUTPUT="
set "INPUT_NAME="
set "FILE_COUNT=0"

REM Подсчет файлов в папке input
for %%F in ("%INPUT_DIR%\*") 
do(
	if exist "%%F"
	(
        set /a FILE_COUNT+=1
        set "FILE_!FILE_COUNT!=%%~fF"
        set "FILE_NAME_!FILE_COUNT!=%%~nxF"
    )
)

REM Если файлов нет
if "%FILE_COUNT%"=="0" (
    echo.
    echo В папке %INPUT_DIR% нет файлов.
    echo.

    set /p INPUT=Введите полный путь к исходному файлу:

    if not exist "%INPUT%" (
        echo.
        echo Файл не найден.
        pause
        goto MENU
    )

    copy "%INPUT%" "%INPUT_DIR%\" >nul

    for %%F in ("%INPUT%") do (
        set "INPUT=%INPUT_DIR%\%%~nxF"
    )
)

REM Если файл один
if "%FILE_COUNT%"=="1" (
    set "INPUT=!FILE_1!"
    echo.
    echo Автоматически выбран файл:
    echo !FILE_NAME_1!
    echo.
)

REM Если найдено несколько файлов
if %FILE_COUNT% GTR 1 (
    echo.
    echo В папке %INPUT_DIR% найдено %FILE_COUNT% файлов.
    echo.
    echo 1. Выбрать один файл
    echo 2. Обработать все файлы
    echo 0. Назад
    echo.

    set /p MODE_CHOICE=Выберите режим:

    if "%MODE_CHOICE%"=="0" goto MENU

    if "%MODE_CHOICE%"=="2" 
	(
        set "BATCH_MODE=1"
        goto ASK_OUTPUT
    )

    if not "%MODE_CHOICE%"=="1" (
        echo.
        echo Некорректный выбор.
        pause
        goto MENU
    )

    echo.
    echo Файлы в папке %INPUT_DIR%:
    echo.

    for /L %%I in (1,1,%FILE_COUNT%) 
	do
	(
        call echo %%I. %%FILE_NAME_%%I%%
    )

    echo.
    set /p FILE_INDEX=Выберите номер файла:

    if not defined FILE_INDEX goto MENU

    call set "INPUT=%%FILE_!FILE_INDEX!%%"

    if not defined INPUT (
        echo.
        echo Неверный выбор.
        pause
        goto MENU
    )
)

:ASK_OUTPUT

REM Имя выходного файла по умолчанию
if "%BATCH_MODE%"=="1" (set "INPUT_NAME=batch_output")
else (for %%F in ("%INPUT%") do set "INPUT_NAME=%%~nF")

REM Запрос имени выходного файла
echo.
set /p OUTPUT=Введите имя для выходного файла (или нажмите Enter, чтобы использовать "%INPUT_NAME%"; расширение можно не указывать):
if "%OUTPUT%"=="" (set "OUTPUT=%INPUT_NAME%")

REM Автоматическое добавление расширения
for %%F in ("%OUTPUT%") 
do (if "%%~xF"=="" (set "OUTPUT=%OUTPUT%.%DEFAULT_EXT%"))

exit /b



:SHOW_SUCCESS
if exist "%OUTPUT_DIR%\%OUTPUT%" (
    echo.
    echo Конвертация успешно завершена.
    echo Файл: %OUTPUT_DIR%\%OUTPUT%
    echo.
    explorer "%OUTPUT_DIR%"
)
exit /b


:TO_PNG
set "DEFAULT_EXT=png"
call :ASK_INPUT
if "%BATCH_MODE%"=="1"
(
    for %%F in ("%INPUT_DIR%\*") do (ffmpeg -y -i "%%F" "%OUTPUT_DIR%\%%~nF.png")
)
else (ffmpeg -y -i "%INPUT%" "%OUTPUT_DIR%\%OUTPUT%")
call :SHOW_SUCCESS
pause
goto MENU


:TO_MP4_H264
set "DEFAULT_EXT=mp4"
call :ASK_INPUT

if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F"
            -c:v libx264 
            -crf 18 
            -preset medium 
            -c:a aac 
            -b:a 192k 
            "%OUTPUT_DIR%\%%~nF.mp4"
    )
)
else
(
    ffmpeg -y -i "%INPUT%" 
        -c:v libx264 
        -crf 18 
        -preset medium 
        -c:a aac 
        -b:a 192k 
        "%OUTPUT_DIR%\%OUTPUT%"
)

call :SHOW_SUCCESS
pause
goto MENU


:TO_MP4_H265
set "DEFAULT_EXT=mp4"
call :ASK_INPUT
ffmpeg -y -i "%INPUT%" -c:v libx265 -crf 24 -preset medium -c:a aac -b:a 192k "%OUTPUT_DIR%\%OUTPUT%"
call :SHOW_SUCCESS
pause
goto MENU


:TO_WEBM
set "DEFAULT_EXT=webm"
call :ASK_INPUT

if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" 
            -c:v libvpx-vp9 
            -crf 30 
            -b:v 0 
            -c:a libopus 
            -b:a 128k 
            "%OUTPUT_DIR%\%%~nF.webm"
    )
) else (
    ffmpeg -y -i "%INPUT%" 
        -c:v libvpx-vp9 
        -crf 30 
        -b:v 0 
        -c:a libopus 
        -b:a 128k 
        "%OUTPUT_DIR%\%OUTPUT%"
)

call :SHOW_SUCCESS
pause
goto MENU



:: ----------------------- OGV (Theora + Vorbis) -----------------------
:TO_OGV
set "DEFAULT_EXT=ogv"
call :ASK_INPUT

set /p VIDEO_QUALITY=Качество видео Theora (0-10) [7]:
if "%VIDEO_QUALITY%"=="" set "VIDEO_QUALITY=7"

set /p AUDIO_QUALITY=Качество аудио Vorbis (-1-10) [5]:
if "%AUDIO_QUALITY%"=="" set "AUDIO_QUALITY=5"

echo.
echo Удалить аудио?
echo 1. Нет
echo 2. Да
set /p REMOVE_AUDIO=Ваш выбор [1]:
if "%REMOVE_AUDIO%"=="" set "REMOVE_AUDIO=1"

set "MAP_VIDEO=-map 0:v:0"
set "MAP_AUDIO="
set "AUDIO_ARGS="

if "%REMOVE_AUDIO%"=="2" (
    set "AUDIO_ARGS=-an"
) else (
    echo.
    echo Доступные аудиодорожки:
    %FFPROBE% -v error ^
        -select_streams a ^
        -show_entries stream=index:stream_tags=language,title ^
        -of compact "%INPUT%"

    echo.
    set /p AUDIO_TRACK=Номер аудиодорожки [0]:
    if "%AUDIO_TRACK%"=="" set "AUDIO_TRACK=0"

    set "MAP_AUDIO=-map 0:a:%AUDIO_TRACK%"
    set "AUDIO_ARGS=-c:a libvorbis -q:a %AUDIO_QUALITY%"
)

ffmpeg -y -i "%INPUT%" 
    %MAP_VIDEO% 
    %MAP_AUDIO% 
    -c:v libtheora -q:v %VIDEO_QUALITY% 
    %AUDIO_ARGS% 
    "%OUTPUT_DIR%\%OUTPUT%"

call :SHOW_SUCCESS
pause
goto MENU




:: ----------------------- MP3 (libmp3lame) -----------------------
:TO_MP3
set "DEFAULT_EXT=mp3"
call :ASK_INPUT
if "%BATCH_MODE%"=="1"
(
	for %%F in ("%INPUT_DIR%\*")
	do (ffmpeg -y -i "%%F" -vn -c:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%%~nF.mp3")
)
else
(
	ffmpeg -y -i "%INPUT%" -vn -c:a libmp3lame -b:a 320k "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU




:: ----------------------- WAV (PCM 16-bit) -----------------------
:TO_WAV
set "DEFAULT_EXT=wav"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" 
            -vn 
            -c:a pcm_s16le 
            -ar 44100 
            -ac 2 
            "%OUTPUT_DIR%\%%~nF.wav"
    )
) else (
    ffmpeg -y -i "%INPUT%" 
        -vn 
        -c:a pcm_s16le 
        -ar 44100 
        -ac 2 
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- FLAC (Lossless) -----------------------
:TO_FLAC
set "DEFAULT_EXT=flac"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" 
            -vn 
            -c:a flac 
            "%OUTPUT_DIR%\%%~nF.flac"
    )
) else (
    ffmpeg -y -i "%INPUT%" 
        -vn 
        -c:a flac 
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- Opus (128 kbps) -----------------------
:TO_OPUS
set "DEFAULT_EXT=opus"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" 
            -vn 
            -c:a libopus 
            -b:a 128k 
            "%OUTPUT_DIR%\%%~nF.opus"
    )
) else (
    ffmpeg -y -i "%INPUT%" 
        -vn 
        -c:a libopus 
        -b:a 128k 
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- AAC (M4A) -----------------------
:TO_AAC
set "DEFAULT_EXT=m4a"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" 
            -vn 
            -c:a aac 
            -b:a 192k 
            "%OUTPUT_DIR%\%%~nF.m4a"
    )
) else (
    ffmpeg -y -i "%INPUT%" 
        -vn 
        -c:a aac 
        -b:a 192k 
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- OGG Vorbis -----------------------
:TO_OGG
set "DEFAULT_EXT=ogg"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -vn ^
            -c:a libvorbis ^
            -q:a 5 ^
            "%OUTPUT_DIR%\%%~nF.ogg"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -vn ^
        -c:a libvorbis ^
        -q:a 5 ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- ALAC (M4A) -----------------------
:TO_ALAC
set "DEFAULT_EXT=m4a"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" -vn -c:a alac "%OUTPUT_DIR%\%%~nF.m4a"
    )
) else (
    ffmpeg -y -i "%INPUT%" -vn -c:a alac "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- AIFF (PCM 16-bit big-endian) -----------------------
:TO_AIFF
set "DEFAULT_EXT=aiff"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" -vn -c:a pcm_s16be "%OUTPUT_DIR%\%%~nF.aiff"
    )
) else (
    ffmpeg -y -i "%INPUT%" -vn -c:a pcm_s16be "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- WavPack (Lossless) -----------------------
:TO_WAVPACK
set "DEFAULT_EXT=wv"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" -vn -c:a wavpack "%OUTPUT_DIR%\%%~nF.wv"
    )
) else (
    ffmpeg -y -i "%INPUT%" -vn -c:a wavpack "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- AC3 (Dolby Digital) -----------------------
:TO_AC3
set "DEFAULT_EXT=ac3"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" -vn -c:a ac3 -b:a 640k "%OUTPUT_DIR%\%%~nF.ac3"
    )
) else (
    ffmpeg -y -i "%INPUT%" -vn -c:a ac3 -b:a 640k "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- E-AC3 (Dolby Digital Plus) -----------------------
:TO_EAC3
set "DEFAULT_EXT=eac3"
call :ASK_INPUT

if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" -vn -c:a eac3 -b:a 768k "%OUTPUT_DIR%\%%~nF.eac3"
    )
) else (
    ffmpeg -y -i "%INPUT%" -vn -c:a eac3 -b:a 768k "%OUTPUT_DIR%\%OUTPUT%"
)

call :SHOW_SUCCESS
pause
goto MENU



::----------------------- MP4 (AV1 + AAC) -----------------------
:TO_MP4_AV1
set "DEFAULT_EXT=mp4"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v libsvtav1 ^
            -crf 30 ^
            -preset 6 ^
            -c:a aac ^
            -b:a 192k ^
            "%OUTPUT_DIR%\%%~nF.mp4"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v libsvtav1 ^
        -crf 30 ^
        -preset 6 ^
        -c:a aac ^
        -b:a 192k ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- MKV (H.264 + Opus) -----------------------
:TO_MKV_H264
set "DEFAULT_EXT=mkv"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v libx264 ^
            -crf 18 ^
            -preset medium ^
            -c:a libopus ^
            -b:a 128k ^
            "%OUTPUT_DIR%\%%~nF.mkv"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v libx264 ^
        -crf 18 ^
        -preset medium ^
        -c:a libopus ^
        -b:a 128k ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- MKV (H.265 + Opus) -----------------------
:TO_MKV_H265
set "DEFAULT_EXT=mkv"
call :ASK_INPUT

if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v libx265 ^
            -crf 24 ^
            -preset medium ^
            -c:a libopus ^
            -b:a 128k ^
            "%OUTPUT_DIR%\%%~nF.mkv"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v libx265 ^
        -crf 24 ^
        -preset medium ^
        -c:a libopus ^
        -b:a 128k ^
        "%OUTPUT_DIR%\%OUTPUT%"
)

call :SHOW_SUCCESS
pause
goto MENU



::----------------------- MKV (AV1 + Opus) -----------------------
:TO_MKV_AV1
set "DEFAULT_EXT=mkv"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v libsvtav1 ^
            -crf 30 ^
            -preset 6 ^
            -c:a libopus ^
            -b:a 128k ^
            "%OUTPUT_DIR%\%%~nF.mkv"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v libsvtav1 ^
        -crf 30 ^
        -preset 6 ^
        -c:a libopus ^
        -b:a 128k ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- MOV (ProRes + PCM) -----------------------
:TO_MOV_PRORES
set "DEFAULT_EXT=mov"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v prores_ks ^
            -profile:v 3 ^
            -pix_fmt yuv422p10le ^
            -c:a pcm_s16le ^
            "%OUTPUT_DIR%\%%~nF.mov"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v prores_ks ^
        -profile:v 3 ^
        -pix_fmt yuv422p10le ^
        -c:a pcm_s16le ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU




::----------------------- AVI (Xvid + MP3) -----------------------
:TO_AVI_XVID
set "DEFAULT_EXT=avi"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -c:v libxvid ^
            -q:v 4 ^
            -c:a libmp3lame ^
            -b:a 192k ^
            "%OUTPUT_DIR%\%%~nF.avi"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -c:v libxvid ^
        -q:v 4 ^
        -c:a libmp3lame ^
        -b:a 192k ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



::----------------------- GIF Animation -----------------------
:TO_GIF
set "DEFAULT_EXT=gif"
call :ASK_INPUT
if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -vf "fps=15,scale=640:-1:flags=lanczos" ^
            "%OUTPUT_DIR%\%%~nF.gif"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        -vf "fps=15,scale=640:-1:flags=lanczos" ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU



:TO_OGV
set "DEFAULT_EXT=ogv"
call :ASK_INPUT

set /p VIDEO_QUALITY=Качество видео Theora (0-10) [7]:
if "%VIDEO_QUALITY%"=="" set "VIDEO_QUALITY=7"

set /p AUDIO_QUALITY=Качество аудио Vorbis (-1-10) [5]:
if "%AUDIO_QUALITY%"=="" set "AUDIO_QUALITY=5"

echo.
echo Удалить аудио?
echo 1. Нет
echo 2. Да
set /p REMOVE_AUDIO=Ваш выбор [1]:
if "%REMOVE_AUDIO%"=="" set "REMOVE_AUDIO=1"

set "MAP_VIDEO=-map 0:v:0"
set "MAP_AUDIO="
set "AUDIO_ARGS="

if "%REMOVE_AUDIO%"=="2" (
    set "AUDIO_ARGS=-an"
) else (
    echo.
    echo Доступные аудиодорожки:
    %FFPROBE% -v error ^
        -select_streams a ^
        -show_entries stream=index:stream_tags=language,title ^
        -of compact "%INPUT%"

    echo.
    set /p AUDIO_TRACK=Номер аудиодорожки [0]:
    if "%AUDIO_TRACK%"=="" set "AUDIO_TRACK=0"

    set "MAP_AUDIO=-map 0:a:%AUDIO_TRACK%"
    set "AUDIO_ARGS=-c:a libvorbis -q:a %AUDIO_QUALITY%"
)

if "%BATCH_MODE%"=="1" (
    for %%F in ("%INPUT_DIR%\*") do (
        ffmpeg -y -i "%%F" ^
            -map 0:v:0 ^
            -c:v libtheora ^
            -q:v %VIDEO_QUALITY% ^
            -c:a libvorbis ^
            -q:a %AUDIO_QUALITY% ^
            "%OUTPUT_DIR%\%%~nF.ogv"
    )
) else (
    ffmpeg -y -i "%INPUT%" ^
        %MAP_VIDEO% ^
        %MAP_AUDIO% ^
        -c:v libtheora ^
        -q:v %VIDEO_QUALITY% ^
        %AUDIO_ARGS% ^
        "%OUTPUT_DIR%\%OUTPUT%"
)
call :SHOW_SUCCESS
pause
goto MENU