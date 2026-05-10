@echo off

:MENU
cls
echo ========================================
echo               Извлечение
echo ========================================
echo.
echo 1. Извлечь аудио без перекодирования
echo 2. Извлечь видео без перекодирования
echo 3. Извлечь субтитры (первый поток)
echo 4. Извлечь кадры в PNG
echo 5. Извлечь встроенную обложку
echo 0. Назад
echo.

set /p CHOICE=Выберите пункт:

if "%CHOICE%"=="1" goto EXTRACT_AUDIO
if "%CHOICE%"=="2" goto EXTRACT_VIDEO
if "%CHOICE%"=="3" goto EXTRACT_SUBS
if "%CHOICE%"=="4" goto EXTRACT_FRAMES
if "%CHOICE%"=="5" goto EXTRACT_COVER
if "%CHOICE%"=="0" exit /b

goto MENU



:EXTRACT_AUDIO
set /p INPUT=Введите путь к исходному файлу:
if not exist "%INPUT%" (
    echo.
    echo Файл не найден.
    pause
    goto MENU
)

set /p OUTPUT=Введите имя выходного файла (без расширения):
if "%OUTPUT%"=="" (
    for %%F in ("%INPUT%") do set "OUTPUT=%%~nF"
)

set "AUDIO_CODEC="

for /f "delims=" %%A in ('
    %FFPROBE% -v error ^
    -select_streams a:0 ^
    -show_entries stream^=codec_name ^
    -of csv^=p^=0 ^
    "%INPUT%"
') do set "AUDIO_CODEC=%%A"

if not defined AUDIO_CODEC (
    echo.
    echo Аудиопоток не найден.
    pause
    goto MENU
)

echo.
echo Обнаружен аудиокодек: %AUDIO_CODEC%
echo.

set "EXT="

if /i "%AUDIO_CODEC%"=="aac" (
    echo Выберите контейнер:
    echo 1. M4A (рекомендуется)
    echo 2. AAC
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=m4a"
    if "%FORMAT_CHOICE%"=="2" set "EXT=aac"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="mp3" (
    echo Выберите контейнер:
    echo 1. MP3
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=mp3"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="flac" (
    echo Выберите контейнер:
    echo 1. FLAC
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=flac"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="opus" (
    echo Выберите контейнер:
    echo 1. OPUS
    echo 2. OGG
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=opus"
    if "%FORMAT_CHOICE%"=="2" set "EXT=ogg"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="vorbis" (
    echo Выберите контейнер:
    echo 1. OGG
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=ogg"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="ac3" (
    echo Выберите контейнер:
    echo 1. AC3
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=ac3"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="eac3" (
    echo Выберите контейнер:
    echo 1. EAC3
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=eac3"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if /i "%AUDIO_CODEC%"=="wavpack" (
    echo Выберите контейнер:
    echo 1. WV
    echo 0. Отмена
    set /p FORMAT_CHOICE=Ваш выбор:
    if "%FORMAT_CHOICE%"=="1" set "EXT=wv"
    if "%FORMAT_CHOICE%"=="0" goto MENU
)

if not defined EXT (
    echo.
    echo Для кодека %AUDIO_CODEC% не настроены совместимые контейнеры.
    pause
    goto MENU
)

echo.
echo Выходной файл:
echo %OUTPUT_DIR%\%OUTPUT%.%EXT%
echo.

ffmpeg -y -i "%INPUT%" -vn -c:a copy "%OUTPUT_DIR%\%OUTPUT%.%EXT%"

if exist "%OUTPUT_DIR%\%OUTPUT%.%EXT%" (
    echo.
    echo Аудио успешно извлечено без перекодирования.
    echo Файл: %OUTPUT_DIR%\%OUTPUT%.%EXT%
    echo.
    explorer "%OUTPUT_DIR%"
)

pause
goto MENU




:EXTRACT_VIDEO
set /p INPUT=Введите путь к исходному файлу:
set /p OUTPUT=Введите имя выходного файла (например video.h264):
ffmpeg -y -i "%INPUT%" -an -c:v copy "%OUTPUT_DIR%\%OUTPUT%"
pause
goto MENU

:EXTRACT_SUBS
set /p INPUT=Введите путь к исходному файлу:
set /p OUTPUT=Введите имя файла субтитров (например subtitles.srt):
ffmpeg -y -i "%INPUT%" -map 0:s:0 "%OUTPUT_DIR%\%OUTPUT%"
pause
goto MENU

:EXTRACT_FRAMES
set /p INPUT=Введите путь к видео:
set /p OUTPUT=Введите шаблон (например frame_%%04d.png):
ffmpeg -y -i "%INPUT%" "%OUTPUT_DIR%\%OUTPUT%"
pause
goto MENU

:EXTRACT_COVER
set /p INPUT=Введите путь к аудиофайлу:
set /p OUTPUT=Введите имя изображения (например cover.jpg):
ffmpeg -y -i "%INPUT%" -an -c:v copy "%OUTPUT_DIR%\%OUTPUT%"
pause
goto MENU