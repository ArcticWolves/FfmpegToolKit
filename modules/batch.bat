@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\batch.bat
rem Пакетная обработка всех медиафайлов папки input по пресету.
rem Результат: output\batch_<пресет>\<имя>.<расширение>
rem
rem Кодеки для пресетов выбираются автоматически (лучшие доступные
rem в сборке, включая аппаратные) через selectors\select_encoding.bat.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Пакетная обработка"
set "COUNT=0"
for /f "delims=" %%F in ('dir /b /a-d "%INPUT_DIR%" 2^>nul') do (
    call "%LIB%" :IsMediaFile "%%F"
    if not errorlevel 1 set /a COUNT+=1
)
echo Медиафайлов в input: %COUNT%
echo.
echo  --- Видео ---------------------------  --- Аудио ---------------
echo   1. MP4 H.264 + AAC                     6. MP3 (VBR ~245k)
echo   2. MP4 HEVC + AAC                      7. M4A AAC 192k
echo   3. MP4 AV1 + AAC                       8. Opus 128k
echo   4. WebM VP9 + Opus                     9. FLAC
echo   5. Сжать для мессенджеров (720p)      10. WAV 16 бит
echo.
echo  --- Прочее --------------------------------------------------
echo  11. GIF (480 px, 15 fps)
echo  12. Ремукс в MKV (без перекодирования)
echo  13. Нормализация громкости -14 LUFS (видео не перекодируется)
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите пресет"
if "%CHOICE%"=="0" goto EXIT_MODULE

set "P_NAME=" & set "P_EXT=" & set "P_POST=" & set "P_ENC=1" & set "P_NEED="
set "PREF_VIDEO=" & set "PREF_AUDIO=" & set "ENC_NO_VIDEO=" & set "ENC_NO_AUDIO="
set "H264=libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
set "SMALL_VF=scale=-2:'min(720,ih)'"
if "%CHOICE%"=="1"  (set "P_NAME=h264" & set "P_EXT=mp4" & set "PREF_VIDEO=%H264%" & set "PREF_AUDIO=aac")
if "%CHOICE%"=="2"  (set "P_NAME=hevc" & set "P_EXT=mp4" & set "PREF_VIDEO=libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar" & set "PREF_AUDIO=aac")
if "%CHOICE%"=="3"  (set "P_NAME=av1" & set "P_EXT=mp4" & set "PREF_VIDEO=libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e" & set "PREF_AUDIO=aac")
if "%CHOICE%"=="4"  (set "P_NAME=vp9" & set "P_EXT=webm" & set "PREF_VIDEO=libvpx-vp9" & set "PREF_AUDIO=libopus")
if "%CHOICE%"=="5"  (set "P_NAME=small" & set "P_EXT=mp4" & set "PREF_VIDEO=%H264%" & set "PREF_AUDIO=aac" & set "P_POST=-vf "!SMALL_VF!" -b:a 128k")
if "%CHOICE%"=="6"  (set "P_NAME=mp3" & set "P_EXT=mp3" & set "P_ENC=0" & set "P_POST=-vn -c:a libmp3lame -q:a 0")
if "%CHOICE%"=="7"  (set "P_NAME=aac" & set "P_EXT=m4a" & set "P_ENC=0" & set "P_POST=-vn -c:a aac -b:a 192k")
if "%CHOICE%"=="8"  (set "P_NAME=opus" & set "P_EXT=opus" & set "P_ENC=0" & set "P_POST=-vn -c:a libopus -b:a 128k")
if "%CHOICE%"=="9"  (set "P_NAME=flac" & set "P_EXT=flac" & set "P_ENC=0" & set "P_POST=-vn -c:a flac")
if "%CHOICE%"=="10" (set "P_NAME=wav" & set "P_EXT=wav" & set "P_ENC=0" & set "P_POST=-vn -c:a pcm_s16le")
if "%CHOICE%"=="11" (set "P_NAME=gif" & set "P_EXT=gif" & set "P_ENC=0" & set "P_POST=-vf "fps=15,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=sierra2_4a" -an -loop 0")
if "%CHOICE%"=="12" (set "P_NAME=remux" & set "P_EXT=mkv" & set "P_ENC=0" & set "P_POST=-map 0 -c copy")
if "%CHOICE%"=="13" (set "P_NAME=loudnorm" & set "P_EXT=*" & set "P_ENC=0")
if not defined P_NAME (call "%LIB%" :InvalidChoice & goto MAIN_MENU)
rem Какой поток обязателен во входном файле (иначе файл пропускается)
for %%C in (1 2 3 4 5 11) do if "%CHOICE%"=="%%C" set "P_NEED=video"
for %%C in (6 7 8 9 10 13) do if "%CHOICE%"=="%%C" set "P_NEED=audio"
if "%COUNT%"=="0" (echo [ERROR] В папке input нет медиафайлов. & pause & goto MAIN_MENU)

rem Кодеки для видеопресетов - один раз для всех файлов
set "ENC_ARGS="
if "%P_ENC%"=="1" (
    set "TARGET_CONTAINER=%P_EXT%"
    call "%SELECTORS_DIR%\select_encoding.bat"
    if errorlevel 1 goto MAIN_MENU
)

set "BATCH_DIR=%OUTPUT_DIR%\batch_%P_NAME%"
if not exist "%BATCH_DIR%" mkdir "%BATCH_DIR%"
echo.
echo Результат: %BATCH_DIR%
echo Существующие файлы с теми же именами будут перезаписаны.
call "%LIB%" :AskYN "Начать обработку %COUNT% файлов?" Y
if errorlevel 1 goto MAIN_MENU

set "DONE=0" & set "FAIL=0" & set "SKIP=0"
for /f "delims=" %%F in ('dir /b /a-d /on "%INPUT_DIR%" 2^>nul') do (
    call "%LIB%" :IsMediaFile "%%F"
    if not errorlevel 1 call :ProcessFile "%INPUT_DIR%\%%F"
)

echo.
echo ============================================================
echo   Готово: %DONE%   Ошибок: %FAIL%   Пропущено: %SKIP%
echo   %BATCH_DIR%
echo ============================================================
echo Подробности ошибок: temp\logs\history.log
echo.
call "%LIB%" :AskYN "Открыть папку с результатами?" N
if not errorlevel 1 start "" "%BATCH_DIR%"
goto MAIN_MENU


rem ============================================================
rem :ProcessFile "путь"
rem ============================================================
:ProcessFile
set "SRC=%~1"
set "NAME=%~n1"
set "EXT=%P_EXT%"
if "%EXT%"=="*" set "EXT=%~x1" & set "EXT=!EXT:~1!"
set "DST=%BATCH_DIR%\%NAME%.%EXT%"
if /i "%DST%"=="%SRC%" (set /a SKIP+=1 & exit /b 0)

echo.
echo ------------------------------------------------------------
echo [%~nx1]
if defined P_NEED (
    set "INPUT_FILE=%SRC%"
    call "%LIB%" :ProbeInput
    if "%P_NEED%"=="video" if not "!IN_HAS_VIDEO!"=="1" (set /a SKIP+=1 & echo   пропуск: нет видео & exit /b 0)
    if "%P_NEED%"=="audio" if not "!IN_HAS_AUDIO!"=="1" (set /a SKIP+=1 & echo   пропуск: нет аудио & exit /b 0)
)
if "%P_NAME%"=="loudnorm" (
    call :LoudnormArgs "%~x1"
    if errorlevel 1 (set /a SKIP+=1 & echo   пропуск: нет аудио или неизвестный контейнер & exit /b 0)
)
set "FF_ARGS=-i "!SRC!" !ENC_ARGS! !P_POST! "!DST!""
call "%LIB%" :RunFF
if errorlevel 1 (set /a FAIL+=1) else (set /a DONE+=1)
exit /b 0


rem Нормализация: видео копируется, аудио перекодируется кодеком,
rem подходящим для исходного контейнера.
:LoudnormArgs
set "INPUT_FILE=%SRC%"
call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" exit /b 1
set "TARGET_CONTAINER=%~1"
set "TARGET_CONTAINER=%TARGET_CONTAINER:~1%"
set "PREF_AUDIO="
set "ENC_AUDIO_NO_COPY=1"
set "AUDIO_CODEC="
call "%SELECTORS_DIR%\select_codec.bat" audio auto
if errorlevel 1 exit /b 1
set "P_POST=-map 0 -c copy -af "loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000" -c:a %AUDIO_CODEC% %AUDIO_CODEC_OPTIONS%"
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
