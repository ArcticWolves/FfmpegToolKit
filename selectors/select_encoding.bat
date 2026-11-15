@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem selectors\select_encoding.bat
rem
rem Экран "Кодирование": показывает выбранные видео/аудиокодеки
rem (по умолчанию - лучшие доступные) и позволяет их изменить.
rem Используется движками конвертации и редактирования.
rem
rem Вход:
rem   TARGET_CONTAINER                 расширение выходного файла
rem   PREF_VIDEO / PREF_AUDIO          предпочтения для "авто"
rem   ENC_NO_VIDEO=1                   выход без видео (-vn)
rem   ENC_NO_AUDIO=1                   выход без аудио (-an)
rem   ENC_VIDEO_NO_COPY=1              есть видеофильтр - copy запрещён
rem   ENC_AUDIO_NO_COPY=1              есть аудиофильтр - copy запрещён
rem   ENC_SILENT=1                     не показывать экран, сразу "авто"
rem
rem Результат (errorlevel 0):
rem   ENC_ARGS   готовые аргументы:  -c:v ... -c:a ...  / -vn / -an
rem   ENC_DESC   краткое описание для экранов подтверждения
rem errorlevel 1 - отмена
rem ============================================================

set "V_CODEC=" & set "V_OPTS=" & set "A_CODEC=" & set "A_OPTS="
set "V_DEFAULT=" & set "A_DEFAULT="

if not "%ENC_NO_VIDEO%"=="1" (
    call "%SELECTORS_DIR%\select_codec.bat" video auto
    if errorlevel 1 (set "V_DEFAULT=1") else (set "V_CODEC=!VIDEO_CODEC!" & set "V_OPTS=!VIDEO_CODEC_OPTIONS!")
)
if not "%ENC_NO_AUDIO%"=="1" (
    call "%SELECTORS_DIR%\select_codec.bat" audio auto
    if errorlevel 1 (set "A_DEFAULT=1") else (set "A_CODEC=!AUDIO_CODEC!" & set "A_OPTS=!AUDIO_CODEC_OPTIONS!")
)

if "%ENC_SILENT%"=="1" goto DONE

:MENU
call "%LIB%" :Header "Кодирование (.%TARGET_CONTAINER%)"
if "%ENC_NO_VIDEO%"=="1" (
    echo   Видео : нет
) else if "%V_DEFAULT%"=="1" (
    echo   Видео : по умолчанию FFmpeg для .%TARGET_CONTAINER%
) else (
    echo   Видео : !V_CODEC! !V_OPTS!
)
if "%ENC_NO_AUDIO%"=="1" (
    echo   Аудио : нет
) else if "%A_DEFAULT%"=="1" (
    echo   Аудио : по умолчанию FFmpeg для .%TARGET_CONTAINER%
) else (
    echo   Аудио : !A_CODEC! !A_OPTS!
)
echo.
if not "%ENC_NO_VIDEO%"=="1" if not "%V_DEFAULT%"=="1" echo  1. Изменить видеокодек / качество
if not "%ENC_NO_AUDIO%"=="1" if not "%A_DEFAULT%"=="1" echo  2. Изменить аудиокодек / качество
echo.
echo  Enter. Продолжить
echo  0.     Отмена
echo.
call "%LIB%" :AskChoice "Выберите действие"

if not defined CHOICE goto DONE
if "%CHOICE%"=="0" (endlocal & exit /b 1)
if "%CHOICE%"=="1" if not "%ENC_NO_VIDEO%"=="1" if not "%V_DEFAULT%"=="1" (
    call "%SELECTORS_DIR%\select_codec.bat" video
    if not errorlevel 1 (set "V_CODEC=!VIDEO_CODEC!" & set "V_OPTS=!VIDEO_CODEC_OPTIONS!")
    goto MENU
)
if "%CHOICE%"=="2" if not "%ENC_NO_AUDIO%"=="1" if not "%A_DEFAULT%"=="1" (
    call "%SELECTORS_DIR%\select_codec.bat" audio
    if not errorlevel 1 (set "A_CODEC=!AUDIO_CODEC!" & set "A_OPTS=!AUDIO_CODEC_OPTIONS!")
    goto MENU
)
call "%LIB%" :InvalidChoice
goto MENU

:DONE
set "ARGS="
set "DESC="
if "%ENC_NO_VIDEO%"=="1" (
    set "ARGS=-vn"
    set "DESC=без видео"
) else if defined V_CODEC (
    set "ARGS=-c:v !V_CODEC! !V_OPTS!"
    set "DESC=видео !V_CODEC!"
) else (
    set "DESC=видео по умолчанию"
)
if "%ENC_NO_AUDIO%"=="1" (
    set "ARGS=!ARGS! -an"
    set "DESC=!DESC!, без аудио"
) else if defined A_CODEC (
    set "ARGS=!ARGS! -c:a !A_CODEC! !A_OPTS!"
    set "DESC=!DESC!, аудио !A_CODEC!"
) else (
    set "DESC=!DESC!, аудио по умолчанию"
)
rem MP4/MOV: индекс в начало файла, чтобы видео сразу играло в браузере.
for %%C in (mp4 m4v m4a mov) do if /i "%TARGET_CONTAINER%"=="%%C" set "ARGS=!ARGS! -movflags +faststart"
endlocal & set "ENC_ARGS=%ARGS%" & set "ENC_DESC=%DESC%"
exit /b 0
