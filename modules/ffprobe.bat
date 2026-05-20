@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================================
rem modules\ffprobe.bat
rem
rem Интерактивный модуль анализа мультимедийных файлов на базе FFprobe.
rem
rem Основная идея:
rem   1. Пользователь выбирает тип анализа.
rem   2. Система показывает результат в человекочитаемом виде.
rem   3. После просмотра предлагает сохранить результат.
rem   4. Поддерживаются TXT, JSON и CSV.
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffprobe.html
rem ============================================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls
echo ============================================================
echo                         FFprobe
echo ============================================================
echo.
echo  1. Сводный отчет
echo  2. Полный JSON
echo  3. Формат контейнера
echo  4. Длительность
echo  5. Размер файла
echo  6. Битрейт
echo  7. Видео кодек
echo  8. Аудио кодек
echo  9. Кодек субтитров
echo 10. Разрешение
echo 11. FPS
echo 12. Pixel Format
echo 13. Количество кадров
echo 14. Количество аудиоканалов
echo 15. Частота дискретизации
echo 16. Язык аудио
echo 17. Проверить наличие видео
echo 18. Проверить наличие аудио
echo 19. Проверить наличие субтитров
echo 20. Сравнить два файла
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="0" goto EXIT_MODULE
if "%CHOICE%"=="20" goto COMPARE_INTERACTIVE

set "INPUT="
set /p "INPUT=Введите путь к файлу: "

if not exist "%INPUT%" (
    echo.
    echo [ERROR] Файл не найден.
    echo.
    pause
    goto MAIN_MENU
)

if "%CHOICE%"=="1" goto SHOW_REPORT
if "%CHOICE%"=="2" goto SHOW_FULL_JSON
if "%CHOICE%"=="3" call :DisplayResult "Container Format" "format_name"        "format"         & goto MAIN_MENU
if "%CHOICE%"=="4" call :DisplayResult "Duration (seconds)" "duration"         "format"         & goto MAIN_MENU
if "%CHOICE%"=="5" call :DisplayResult "File Size (bytes)" "size"              "format"         & goto MAIN_MENU
if "%CHOICE%"=="6" call :DisplayResult "Bitrate"          "bit_rate"           "format"         & goto MAIN_MENU
if "%CHOICE%"=="7" call :DisplayResult "Video Codec"      "codec_name"         "stream_v"       & goto MAIN_MENU
if "%CHOICE%"=="8" call :DisplayResult "Audio Codec"      "codec_name"         "stream_a"       & goto MAIN_MENU
if "%CHOICE%"=="9" call :DisplayResult "Subtitle Codec"   "codec_name"         "stream_s"       & goto MAIN_MENU
if "%CHOICE%"=="10" call :DisplayResolution                                                   & goto MAIN_MENU
if "%CHOICE%"=="11" call :DisplayResult "FPS"             "avg_frame_rate"     "stream_v"       & goto MAIN_MENU
if "%CHOICE%"=="12" call :DisplayResult "Pixel Format"    "pix_fmt"            "stream_v"       & goto MAIN_MENU
if "%CHOICE%"=="13" call :DisplayFrameCount                                                   & goto MAIN_MENU
if "%CHOICE%"=="14" call :DisplayResult "Audio Channels"  "channels"           "stream_a"       & goto MAIN_MENU
if "%CHOICE%"=="15" call :DisplayResult "Sample Rate"     "sample_rate"        "stream_a"       & goto MAIN_MENU
if "%CHOICE%"=="16" call :DisplayResult "Audio Language"  "language"           "stream_tag_a"   & goto MAIN_MENU
if "%CHOICE%"=="17" call :DisplayPresence "Has Video"     "v"                  & goto MAIN_MENU
if "%CHOICE%"=="18" call :DisplayPresence "Has Audio"     "a"                  & goto MAIN_MENU
if "%CHOICE%"=="19" call :DisplayPresence "Has Subtitles" "s"                  & goto MAIN_MENU

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU

rem ============================================================================
rem Сводный отчет
rem ============================================================================
:SHOW_REPORT
cls
echo ============================================================
echo                       FFprobe Report
echo ============================================================
echo.
echo File:
echo %INPUT%
echo.

call :DisplayResultNoSave "Container Format" "format_name" "format"
call :DisplayResultNoSave "Duration (seconds)" "duration" "format"
call :DisplayResultNoSave "Video Codec" "codec_name" "stream_v"
call :DisplayResultNoSave "Audio Codec" "codec_name" "stream_a"
call :DisplayResolutionNoSave
call :DisplayResultNoSave "FPS" "avg_frame_rate" "stream_v"

call :PromptSaveFullReport
goto MAIN_MENU

rem ============================================================================
rem Полный JSON
rem ============================================================================
:SHOW_FULL_JSON
cls
echo ============================================================
echo                         Full JSON
echo ============================================================
echo.

"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%"

call :PromptSaveRawJSON
goto MAIN_MENU

rem ============================================================================
rem Сравнение двух файлов
rem ============================================================================
:COMPARE_INTERACTIVE
cls

set "INPUT="
set "INPUT2="

set /p "INPUT=Введите путь к первому файлу: "
set /p "INPUT2=Введите путь ко второму файлу: "

if not exist "%INPUT%" (
    echo.
    echo [ERROR] Первый файл не найден.
    pause
    goto MAIN_MENU
)

if not exist "%INPUT2%" (
    echo.
    echo [ERROR] Второй файл не найден.
    pause
    goto MAIN_MENU
)

cls
echo ============================================================
echo FILE 1
echo ============================================================
echo.
call :ShowQuickReport "%INPUT%"

echo.
echo ============================================================
echo FILE 2
echo ============================================================
echo.
call :ShowQuickReport "%INPUT2%"

pause
goto MAIN_MENU

rem ============================================================================
rem Универсальное отображение результата
rem ============================================================================
:DisplayResult
set "TITLE=%~1"
set "ENTRY=%~2"
set "MODE=%~3"

call :GetValue "%ENTRY%" "%MODE%"
call :ShowValue "%TITLE%" "%RESULT%"
call :PromptSaveResult "%TITLE%" "%RESULT%"
exit /b 0

:DisplayResultNoSave
set "TITLE=%~1"
set "ENTRY=%~2"
set "MODE=%~3"

call :GetValue "%ENTRY%" "%MODE%"
echo %TITLE%: %RESULT%
exit /b 0

rem ============================================================================
rem Получение значения
rem ============================================================================
:GetValue
set "ENTRY=%~1"
set "MODE=%~2"
set "RESULT="

if /I "%MODE%"=="format" (
    for /f "delims=" %%I in ('
        "%FFPROBE%" -v error ^
        -show_entries format^=%ENTRY% ^
        -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
    ') do set "RESULT=%%I"
)

if /I "%MODE%"=="stream_v" (
    for /f "delims=" %%I in ('
        "%FFPROBE%" -v error ^
        -select_streams v:0 ^
        -show_entries stream^=%ENTRY% ^
        -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
    ') do set "RESULT=%%I"
)

if /I "%MODE%"=="stream_a" (
    for /f "delims=" %%I in ('
        "%FFPROBE%" -v error ^
        -select_streams a:0 ^
        -show_entries stream^=%ENTRY% ^
        -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
    ') do set "RESULT=%%I"
)

if /I "%MODE%"=="stream_s" (
    for /f "delims=" %%I in ('
        "%FFPROBE%" -v error ^
        -select_streams s:0 ^
        -show_entries stream^=%ENTRY% ^
        -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
    ') do set "RESULT=%%I"
)

if /I "%MODE%"=="stream_tag_a" (
    for /f "delims=" %%I in ('
        "%FFPROBE%" -v error ^
        -select_streams a:0 ^
        -show_entries stream_tags^=%ENTRY% ^
        -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
    ') do set "RESULT=%%I"
)

if not defined RESULT set "RESULT=N/A"
exit /b 0

rem ============================================================================
rem Разрешение
rem ============================================================================
:DisplayResolution
for /f "delims=" %%I in ('
    "%FFPROBE%" -v error ^
    -select_streams v:0 ^
    -show_entries stream^=width,height ^
    -of csv^=s^=x:p^=0 "%INPUT%"
') do set "RESULT=%%I"

if not defined RESULT set "RESULT=N/A"

call :ShowValue "Resolution" "%RESULT%"
call :PromptSaveResult "Resolution" "%RESULT%"
exit /b 0

:DisplayResolutionNoSave
for /f "delims=" %%I in ('
    "%FFPROBE%" -v error ^
    -select_streams v:0 ^
    -show_entries stream^=width,height ^
    -of csv^=s^=x:p^=0 "%INPUT%"
') do set "RESULT=%%I"

if not defined RESULT set "RESULT=N/A"
echo Resolution: %RESULT%
exit /b 0

rem ============================================================================
rem Количество кадров
rem ============================================================================
:DisplayFrameCount
for /f "delims=" %%I in ('
    "%FFPROBE%" -v error -count_frames ^
    -select_streams v:0 ^
    -show_entries stream^=nb_read_frames ^
    -of default^=nokey^=1:noprint_wrappers^=1 "%INPUT%"
') do set "RESULT=%%I"

if not defined RESULT set "RESULT=N/A"

call :ShowValue "Frame Count" "%RESULT%"
call :PromptSaveResult "Frame Count" "%RESULT%"
exit /b 0

rem ============================================================================
rem Проверка наличия потока
rem ============================================================================
:DisplayPresence
set "TITLE=%~1"
set "STREAM=%~2"

"%FFPROBE%" -v error -select_streams %STREAM% ^
-show_entries stream=index ^
-of csv^=p^=0 "%INPUT%" >nul 2>&1

if errorlevel 1 (
    set "RESULT=0"
) else (
    set "RESULT=1"
)

call :ShowValue "%TITLE%" "%RESULT%"
call :PromptSaveResult "%TITLE%" "%RESULT%"
exit /b 0

rem ============================================================================
rem Отображение значения
rem ============================================================================
:ShowValue
cls
echo ============================================================
echo %~1
echo ============================================================
echo.
echo File:
echo %INPUT%
echo.
echo Value:
echo %~2
echo.
exit /b 0

rem ============================================================================
rem Сохранение результата
rem ============================================================================
:PromptSaveResult
set "TITLE=%~1"
set "VALUE=%~2"

echo.
set "SAVE_RESULT="
set /p "SAVE_RESULT=Сохранить результат? (Y/N): "

if /I not "%SAVE_RESULT%"=="Y" exit /b 0

echo.
echo 1. TXT
echo 2. JSON
echo 3. CSV
echo 0. Отмена
echo.

set "FORMAT_CHOICE="
set /p "FORMAT_CHOICE=Выберите формат: "

for %%F in ("%INPUT%") do set "BASE_NAME=%%~nF"

if "%FORMAT_CHOICE%"=="1" (
    set "OUTPUT_FILE=%LOG_DIR%\%BASE_NAME%_%TITLE%.txt"
    > "%OUTPUT_FILE%" (
        echo %TITLE%: %VALUE%
        echo File: %INPUT%
    )
)

if "%FORMAT_CHOICE%"=="2" (
    set "OUTPUT_FILE=%LOG_DIR%\%BASE_NAME%_%TITLE%.json"
    > "%OUTPUT_FILE%" (
        echo {
        echo   "title": "%TITLE%",
        echo   "value": "%VALUE%",
        echo   "file": "%INPUT:\=\\%"
        echo }
    )
)

if "%FORMAT_CHOICE%"=="3" (
    set "OUTPUT_FILE=%LOG_DIR%\%BASE_NAME%_%TITLE%.csv"
    > "%OUTPUT_FILE%" (
        echo Title,Value,File
        echo "%TITLE%","%VALUE%","%INPUT%"
    )
)

if "%FORMAT_CHOICE%"=="0" exit /b 0

echo.
echo Файл сохранён:
echo %OUTPUT_FILE%
echo.
pause
exit /b 0

rem ============================================================================
rem Сохранение полного JSON
rem ============================================================================
:PromptSaveRawJSON
echo.
set "SAVE_JSON="
set /p "SAVE_JSON=Сохранить JSON в logs? (Y/N): "

if /I not "%SAVE_JSON%"=="Y" (
    pause
    exit /b 0
)

for %%F in ("%INPUT%") do (
    set "OUTPUT_FILE=%LOG_DIR%\%%~nF_ffprobe.json"
)

"%FFPROBE%" -v quiet -print_format json -show_format -show_streams "%INPUT%" > "%OUTPUT_FILE%"

echo.
echo Файл сохранён:
echo %OUTPUT_FILE%
echo.
pause
exit /b 0

rem ============================================================================
rem Сохранение сводного отчёта
rem ============================================================================
:PromptSaveFullReport
echo.
set "SAVE_REPORT="
set /p "SAVE_REPORT=Сохранить сводный отчет? (Y/N): "

if /I "%SAVE_REPORT%"=="Y" (
    for %%F in ("%INPUT%") do (
        set "OUTPUT_FILE=%LOG_DIR%\%%~nF_report.txt"
    )

    (
        echo FFprobe Report
        echo File: %INPUT%
        echo.
        call :ShowQuickReport "%INPUT%"
    ) > "%OUTPUT_FILE%"

    echo.
    echo Файл сохранён:
    echo %OUTPUT_FILE%
)

echo.
pause
exit /b 0

rem ============================================================================
rem Быстрый отчёт
rem ============================================================================
:ShowQuickReport
set "INPUT=%~1"

call :GetValue "format_name" "format"
echo Container Format: %RESULT%

call :GetValue "duration" "format"
echo Duration: %RESULT%

call :GetValue "codec_name" "stream_v"
echo Video Codec: %RESULT%

call :GetValue "codec_name" "stream_a"
echo Audio Codec: %RESULT%

for /f "delims=" %%I in ('
    "%FFPROBE%" -v error ^
    -select_streams v:0 ^
    -show_entries stream^=width,height ^
    -of csv^=s^=x:p^=0 "%INPUT%"
') do set "RESULT=%%I"
echo Resolution: %RESULT%

exit /b 0

rem ============================================================================
rem Выход
rem ============================================================================
:EXIT_MODULE
endlocal
exit /b 0