@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem selectors\select_codec.bat
rem
rem Выбор видео- или аудиокодека для контейнера.
rem Показываются только энкодеры, которые есть в текущей сборке FFmpeg
rem (и аппаратные, которые реально работают на этом ПК).
rem
rem Аргументы:
rem   %1  video | audio
rem   %2  auto  - без меню: лучший доступный кодек с настройками по умолчанию
rem
rem Вход:
rem   TARGET_CONTAINER          расширение контейнера (mp4, mkv, webm...)
rem   PREF_VIDEO / PREF_AUDIO   порядок предпочтения для "авто" (необязательно)
rem   ENC_VIDEO_NO_COPY=1 / ENC_AUDIO_NO_COPY=1   запретить copy (есть фильтр)
rem
rem Результат:
rem   VIDEO_CODEC + VIDEO_CODEC_OPTIONS  или  AUDIO_CODEC + AUDIO_CODEC_OPTIONS
rem   errorlevel 1 - отмена или для контейнера нет списка кодеков
rem
rem Модуль кодека: modules\codecs\<video|audio>\<энкодер>.bat
rem   Первая строка - описание для меню:  @rem @label Текст
rem   Параметр %1 = auto  ->  не задавать вопросов.
rem ============================================================

set "KIND=%~1"
if /i not "%KIND%"=="audio" set "KIND=video"
set "MODE=%~2"

if /i "%KIND%"=="video" (
    set "PREF=%PREF_VIDEO%"
    set "NO_COPY=%ENC_VIDEO_NO_COPY%"
    set "TITLE=Видеокодек"
) else (
    set "PREF=%PREF_AUDIO%"
    set "NO_COPY=%ENC_AUDIO_NO_COPY%"
    set "TITLE=Аудиокодек"
)

call :GetList %KIND% "%TARGET_CONTAINER%"
if not defined LIST (
    endlocal
    exit /b 1
)

rem ------------------------------------------------------------
rem Доступные варианты
rem ------------------------------------------------------------
set "COUNT=0"
for %%E in (%LIST%) do call :AddCandidate %%E

if "%COUNT%"=="0" (
    echo.
    echo [ERROR] Для контейнера %TARGET_CONTAINER% нет доступных кодеков ^(%KIND%^).
    pause
    endlocal
    exit /b 1
)

rem ------------------------------------------------------------
rem Вариант "авто"
rem ------------------------------------------------------------
set "AUTO="
if defined PREF for %%E in (%PREF%) do call :TryAuto %%E
if not defined AUTO for /L %%I in (%COUNT%,-1,1) do call :TryFirst %%I
if not defined AUTO set "AUTO=%ENC_1%"

if /i "%MODE%"=="auto" (
    set "PICK=%AUTO%"
    set "PICK_MODE=auto"
    goto APPLY
)

:MENU
call "%LIB%" :Header "%TITLE% для .%TARGET_CONTAINER%"
for /L %%I in (1,1,%COUNT%) do call :ShowItem %%I
echo.
echo  * - рекомендуемый вариант для этой сборки
echo.
echo  Enter. Рекомендуемый с настройками по умолчанию ^(%AUTO%^)
echo  0.     Отмена
echo.
call "%LIB%" :AskChoice "Выберите кодек"

if not defined CHOICE (
    set "PICK=%AUTO%"
    set "PICK_MODE=auto"
    goto APPLY
)
if "%CHOICE%"=="0" (endlocal & exit /b 1)
call "%LIB%" :IsInt "%CHOICE%"
if errorlevel 1 (call "%LIB%" :InvalidChoice & goto MENU)
if %CHOICE% LSS 1 (call "%LIB%" :InvalidChoice & goto MENU)
if %CHOICE% GTR %COUNT% (call "%LIB%" :InvalidChoice & goto MENU)
set "PICK=!ENC_%CHOICE%!"
set "PICK_MODE="
echo.
echo Настройки %PICK% ^(Enter = значение по умолчанию^):

:APPLY
set "VIDEO_CODEC="
set "AUDIO_CODEC="
call "%CODECS_DIR%\%KIND%\%PICK%.bat" %PICK_MODE%

if /i "%KIND%"=="video" if not defined VIDEO_CODEC (endlocal & exit /b 1)
if /i "%KIND%"=="audio" if not defined AUDIO_CODEC (endlocal & exit /b 1)

rem Значения формируются модулями кодеков (без спецсимволов cmd).
if /i "%KIND%"=="video" (
    endlocal & set "VIDEO_CODEC=%VIDEO_CODEC%" & set "VIDEO_CODEC_OPTIONS=%VIDEO_CODEC_OPTIONS%"
) else (
    endlocal & set "AUDIO_CODEC=%AUDIO_CODEC%" & set "AUDIO_CODEC_OPTIONS=%AUDIO_CODEC_OPTIONS%"
)
exit /b 0


rem ============================================================
rem Вспомогательные подпрограммы для индексных переменных
rem ENC_n / LBL_n (без !X_%%I! - так надёжнее в любом cmd)
rem ============================================================
:AddCandidate
if /i "%1"=="copy" if "%NO_COPY%"=="1" exit /b 0
call "%LIB%" :IsAvailable %1
if errorlevel 1 exit /b 0
set "_mod=%CODECS_DIR%\%KIND%\%1.bat"
if not exist "%_mod%" exit /b 0
set /a COUNT+=1
set "ENC_%COUNT%=%1"
rem Описание - первая строка модуля:  @rem @label Текст
set "_l1="
findstr /b /c:"@rem @label " "%_mod%" > "%TEMP_DIR%\codec_label.tmp" 2>nul
set /p "_l1=" < "%TEMP_DIR%\codec_label.tmp"
set "LBL_%COUNT%=%1"
if defined _l1 if not "%_l1:@rem @label =%"=="%_l1%" set "LBL_%COUNT%=%_l1:@rem @label =%"
exit /b 0

:TryAuto
if defined AUTO exit /b 0
for /L %%I in (1,1,%COUNT%) do call :TryAutoIdx %%I %1
exit /b 0

:TryAutoIdx
call set "_e=%%ENC_%1%%"
if "%_e%"=="%2" set "AUTO=%2"
exit /b 0

:TryFirst
call set "_e=%%ENC_%1%%"
if not "%_e%"=="copy" set "AUTO=%_e%"
exit /b 0

:ShowItem
call set "_e=%%ENC_%1%%"
call set "_l=%%LBL_%1%%"
set "_mark=  "
if "%_e%"=="%AUTO%" set "_mark=* "
set "_n=  %1"
echo  %_mark%%_n:~-3%. !_l!
exit /b 0


rem ============================================================
rem :GetList kind container  ->  LIST
rem Порядок в списке = порядок в меню. Первый не-copy доступный
rem кодек становится "авто", если PREF_* не задан.
rem ============================================================
:GetList
set "LIST="
set "C=%~2"
if /i "%C%"=="m4v" set "C=mp4"
if /i "%C%"=="m4a" set "C=mp4"
if /i "%C%"=="mts" set "C=ts"
if /i "%C%"=="m2ts" set "C=ts"
if /i "%C%"=="mpeg" set "C=mpg"
if /i "%C%"=="ogv" set "C=ogg"

if /i "%~1"=="video" (
    if /i "%C%"=="mp4"  set "LIST=copy libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264 libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e libvvenc mpeg4"
    if /i "%C%"=="mov"  set "LIST=copy prores_ks dnxhd libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264 libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar mpeg4"
    if /i "%C%"=="mkv"  set "LIST=copy libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264 libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf libkvazaar libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e libvvenc libvpx-vp9 libvpx libtheora ffv1 utvideo prores_ks mpeg4"
    if /i "%C%"=="webm" set "LIST=copy libvpx-vp9 libsvtav1 av1_nvenc av1_qsv av1_amf libaom-av1 librav1e libvpx"
    if /i "%C%"=="ogg"  set "LIST=copy libtheora"
    if /i "%C%"=="avi"  set "LIST=copy mpeg4 libx264 libopenh264 h264_mf utvideo ffv1"
    if /i "%C%"=="ts"   set "LIST=copy libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264 libx265 hevc_nvenc hevc_qsv hevc_amf hevc_mf mpeg2video"
    if /i "%C%"=="flv"  set "LIST=copy libx264 h264_nvenc h264_qsv h264_amf h264_mf libopenh264"
    if /i "%C%"=="mpg"  set "LIST=copy mpeg2video"
) else (
    if /i "%C%"=="mp4"  set "LIST=copy aac alac libopus libmp3lame ac3 eac3"
    if /i "%C%"=="mov"  set "LIST=copy aac alac pcm_s16le pcm_s24le ac3"
    if /i "%C%"=="mkv"  set "LIST=copy aac libopus libvorbis flac libmp3lame ac3 eac3 alac pcm_s16le pcm_s24le"
    if /i "%C%"=="webm" set "LIST=copy libopus libvorbis"
    if /i "%C%"=="ogg"  set "LIST=copy libvorbis libopus flac"
    if /i "%C%"=="opus" set "LIST=copy libopus"
    if /i "%C%"=="mp3"  set "LIST=copy libmp3lame"
    if /i "%C%"=="flac" set "LIST=copy flac"
    if /i "%C%"=="wav"  set "LIST=copy pcm_s16le pcm_s24le pcm_f32le"
    if /i "%C%"=="aac"  set "LIST=copy aac"
    if /i "%C%"=="ac3"  set "LIST=copy ac3"
    if /i "%C%"=="avi"  set "LIST=copy libmp3lame ac3 pcm_s16le"
    if /i "%C%"=="ts"   set "LIST=copy aac ac3 libmp3lame"
    if /i "%C%"=="flv"  set "LIST=copy aac libmp3lame"
    if /i "%C%"=="mpg"  set "LIST=copy ac3 libmp3lame"
)
exit /b 0
