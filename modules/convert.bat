@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\convert.bat
rem Раздел "Конвертация".
rem
rem Таблица форматов: ключ | название | нужные энкодеры (любой из)
rem Ключ = имя профиля modules\convert\<ключ>.bat.
rem Форматы, для которых в сборке нет ни одного энкодера, помечаются
rem и не запускаются. Профили видео/аудио используют lib\transcode.bat,
rem изображения - convert\_image.bat, анимация - convert\_anim.bat.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

set "N=0"
set "LINES=0"
call :Section "Видео"
call :Item "mp4_h264|MP4  H.264 + AAC  - совместимо со всем|libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
call :Item "mp4_h265|MP4  HEVC + AAC   - вдвое меньше при том же качестве|libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar"
call :Item "mp4_av1|MP4  AV1 + AAC    - лучшее сжатие|libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e"
call :Item "mkv|MKV  любые кодеки - H.264 + Opus по умолчанию|libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
call :Item "webm_vp9|WebM VP9 + Opus   - для сайтов|libvpx-vp9 libsvtav1 libaom-av1"
call :Item "mov_prores|MOV  ProRes       - для монтажа|prores_ks"
call :Item "ogv|OGV  Theora + Vorbis|libtheora"
call :Section "Анимация"
call :Item "gif|GIF с оптимальной палитрой|gif"
call :Item "webp_anim|Анимированный WebP - меньше и качественнее GIF|libwebp"
call :Item "apng|APNG - анимированный PNG|apng"
call :Section "Аудио"
call :Item "mp3|MP3|libmp3lame"
call :Item "aac|M4A  AAC|aac"
call :Item "alac|M4A  ALAC - без потерь|alac"
call :Item "opus|Opus|libopus"
call :Item "ogg|OGG  Vorbis|libvorbis"
call :Item "flac|FLAC - без потерь|flac"
call :Item "wav|WAV  PCM|pcm_s16le"
call :Section "Изображения (кадр из видео или конвертация картинки)"
call :Item "png|PNG|png"
call :Item "jpeg|JPEG|mjpeg"
call :Item "webp|WebP|libwebp"
call :Item "avif|AVIF|libaom-av1"
call :Item "jxl|JPEG XL|libjxl"
call :Item "tiff|TIFF|tiff"
call :Item "bmp|BMP|bmp"
call :Item "ico|ICO - иконка Windows|png"
call :Item "qoi|QOI|qoi"
call :Section "Изображения для профессиональной работы"
call :Item "dpx|DPX  - кино, 10/16 бит|dpx"
call :Item "exr|EXR  - HDR, VFX|exr"
call :Item "hdr|HDR  - Radiance RGBE|hdr"
call :Item "jp2|JPEG 2000|jpeg2000"
call :Item "pam|PAM|pam"
call :Item "pnm|PBM / PGM / PPM (Netpbm)|ppm"

:MAIN_MENU
call "%LIB%" :Header "Конвертация"
for /L %%I in (1,1,%LINES%) do call :ShowLine %%I
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите формат"
if "%CHOICE%"=="0" goto EXIT_MODULE
call "%LIB%" :IsInt "%CHOICE%"
if errorlevel 1 (call "%LIB%" :InvalidChoice & goto MAIN_MENU)
if %CHOICE% LSS 1 (call "%LIB%" :InvalidChoice & goto MAIN_MENU)
if %CHOICE% GTR %N% (call "%LIB%" :InvalidChoice & goto MAIN_MENU)

if not "!OK_%CHOICE%!"=="1" (
    echo.
    echo [ERROR] В текущей сборке FFmpeg нет нужного энкодера:
    echo         !REQ_%CHOICE%!
    echo         Замените FFmpeg в source\bin на более полную сборку.
    echo.
    pause
    goto MAIN_MENU
)

call :OpenProfile "!KEY_%CHOICE%!"
goto MAIN_MENU


rem ============================================================
rem :OpenProfile ключ - выбрать входной файл и запустить профиль
rem ============================================================
:OpenProfile
set "PROFILE=%MODULES_DIR%\convert\%~1.bat"
if not exist "%PROFILE%" (
    echo [ERROR] Не найден профиль: %PROFILE%
    pause
    exit /b 1
)
setlocal
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 (endlocal & exit /b 0)
call "%PROFILE%"
endlocal
exit /b 0


rem ============================================================
rem Построение меню
rem ============================================================
:ShowLine
call set "_l=%%LINE_%1%%"
echo(!_l!
exit /b 0

:Section
set /a LINES+=1
set "LINE_%LINES%="
set /a LINES+=1
set "LINE_%LINES%= --- %~1 ---"
exit /b 0

:Item
for /f "tokens=1-3 delims=|" %%A in ("%~1") do (
    set /a N+=1
    set "KEY_!N!=%%A"
    set "REQ_!N!=%%C"
    set "OK_!N!=0"
    call "%LIB%" :PickBest _best "%%C"
    if defined _best set "OK_!N!=1"
    set "_n=   !N!"
    set "_line=!_n:~-3!. %%B"
    if not defined _best set "_line=!_line!   [нет в сборке]"
    set /a LINES+=1
    set "LINE_!LINES!=!_line!"
)
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
