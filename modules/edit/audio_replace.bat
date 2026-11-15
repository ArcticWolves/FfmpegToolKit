@echo off
rem ============================================================
rem modules\edit\audio_replace.bat
rem Заменить аудиодорожку, добавить вторую или подмешать музыку.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Аудиодорожка"
echo   1. Заменить звук новым файлом
echo   2. Добавить как дополнительную дорожку
echo   3. Подмешать фоновую музыку к оригинальному звуку
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
if "%CHOICE%"=="0" exit /b 0
set "MODE=%CHOICE%"
if not "%MODE%"=="1" if not "%MODE%"=="2" if not "%MODE%"=="3" (call "%LIB%" :InvalidChoice & exit /b 0)

call "%LIB%" :AskFile AUDIO "Аудиофайл (mp3, wav, m4a...)"
if errorlevel 1 exit /b 0
set "EXTRA_INPUTS=-i "!AUDIO!""
set "PREF_VIDEO=copy"

if "%MODE%"=="1" (
    call "%LIB%" :AskYN "Обрезать по более короткому из файлов?" Y
    if not errorlevel 1 set "EXTRA_OUT_OPTS=-shortest"
    set "MAP_ARGS=-map 0:v -map 1:a"
    set "OUTPUT_SUFFIX=newaudio"
)
if "%MODE%"=="2" (
    call "%LIB%" :Ask LANG "Язык новой дорожки (rus, eng...)" "rus"
    set "MAP_ARGS=-map 0 -map 1:a"
    set "EXTRA_OUT_OPTS=-metadata:s:a:1 language=!LANG!"
    set "OUTPUT_SUFFIX=2audio"
)
if "%MODE%"=="3" (
    if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В видео нет звука для смешивания. & pause & exit /b 1)
    call "%LIB%" :AskNum MUSIC_VOL "Громкость музыки, 0.0-1.0" 0.25
    set "FILTER_COMPLEX=[1:a]volume=!MUSIC_VOL![m];[0:a][m]amix=inputs=2:duration=first:dropout_transition=3:normalize=0[a]"
    set "MAP_ARGS=-map 0:v -map "[a]""
    set "ENC_AUDIO_NO_COPY=1"
    set "OUTPUT_SUFFIX=music"
)
set "JOB_TITLE=Аудиодорожка"
call "%TRANSCODE%"
