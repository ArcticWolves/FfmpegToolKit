@echo off
rem ============================================================
rem lib\transcode.bat
rem
rem Общий движок перекодирования для конвертации и редактирования.
rem Модуль (формат или операция) задаёт параметры, движок делает
rem всё остальное:
rem   выбор выходного файла -> выбор кодеков -> сборка команды ->
rem   запуск -> результат.
rem
rem Вызов:  call "%TRANSCODE%"
rem Вызывается без setlocal: модули уже изолированы своими меню
rem (convert.bat, edit.bat).
rem
rem Вход (задаёт модуль операции):
rem   INPUT_FILE        входной файл (обязательно)
rem   OUTPUT_SUFFIX     суффикс имени выходного файла
rem   OUTPUT_EXT        расширение (по умолчанию как у входного)
rem   INPUT_OPTS        параметры перед -i (например -ss/-to)
rem   EXTRA_INPUTS      дополнительные входы: -i "файл" ...
rem   VIDEO_FILTER      цепочка -vf
rem   AUDIO_FILTER      цепочка -af
rem   FILTER_COMPLEX    граф -filter_complex (вместо -vf/-af)
rem   MAP_ARGS          явные -map ... (например для FILTER_COMPLEX)
rem   EXTRA_OUT_OPTS    дополнительные параметры вывода
rem   ENC_NO_VIDEO / ENC_NO_AUDIO           убрать видео / аудио
rem   ENC_VIDEO_NO_COPY / ENC_AUDIO_NO_COPY запретить copy
rem   PREF_VIDEO / PREF_AUDIO               предпочтения кодеков
rem   EDIT_MODE=1       нетронутые фильтрами потоки по умолчанию copy
rem   ENC_FIXED_ARGS    готовые параметры кодеков (без экрана выбора),
rem                     например "-map 0 -c copy"
rem
rem errorlevel: 0 = готово, 1 = ошибка, 2 = отмена
rem ============================================================

call "%LIB%" :RequireInput
if errorlevel 1 exit /b 1

if not defined OUTPUT_EXT set "OUTPUT_EXT=%INPUT_EXT%"
if not defined OUTPUT_EXT for %%F in ("%INPUT_FILE%") do set "OUTPUT_EXT=%%~xF"
if "%OUTPUT_EXT:~0,1%"=="." set "OUTPUT_EXT=%OUTPUT_EXT:~1%"
if not defined OUTPUT_SUFFIX set "OUTPUT_SUFFIX=edit"

rem Фильтр означает перекодирование соответствующего потока
if defined VIDEO_FILTER set "ENC_VIDEO_NO_COPY=1"
if defined AUDIO_FILTER set "ENC_AUDIO_NO_COPY=1"

rem Режим редактирования (EDIT_MODE=1): нетронутые потоки по умолчанию
rem копируются без потерь.
if "%EDIT_MODE%"=="1" (
    if not defined PREF_AUDIO if not "%ENC_AUDIO_NO_COPY%"=="1" set "PREF_AUDIO=copy"
    if not defined PREF_VIDEO if not "%ENC_VIDEO_NO_COPY%"=="1" set "PREF_VIDEO=copy"
)

call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 2

set "TARGET_CONTAINER=%OUTPUT_EXT%"
if defined ENC_FIXED_ARGS (
    set "ENC_ARGS=!ENC_FIXED_ARGS!"
    set "ENC_DESC=!ENC_FIXED_ARGS!"
) else (
    call "%SELECTORS_DIR%\select_encoding.bat"
    if errorlevel 1 exit /b 2
)

rem ------------------------------------------------------------
rem Сборка команды (через !переменные! - безопасно для спецсимволов)
rem ------------------------------------------------------------
set "FF_ARGS=!INPUT_OPTS! -i "!INPUT_FILE!" !EXTRA_INPUTS!"
if defined FILTER_COMPLEX set "FF_ARGS=!FF_ARGS! -filter_complex "!FILTER_COMPLEX!""
if defined MAP_ARGS       set "FF_ARGS=!FF_ARGS! !MAP_ARGS!"
if defined VIDEO_FILTER   set "FF_ARGS=!FF_ARGS! -vf "!VIDEO_FILTER!""
if defined AUDIO_FILTER   set "FF_ARGS=!FF_ARGS! -af "!AUDIO_FILTER!""
set "FF_ARGS=!FF_ARGS! !ENC_ARGS! !EXTRA_OUT_OPTS! "!OUTPUT_FILE!""

if defined JOB_TITLE (call "%LIB%" :Header "!JOB_TITLE!") else (call "%LIB%" :Header "Подтверждение")
echo Вход   : !INPUT_FILE!
if defined VIDEO_FILTER   echo Видео  : !VIDEO_FILTER!
if defined AUDIO_FILTER   echo Аудио  : !AUDIO_FILTER!
if defined FILTER_COMPLEX echo Граф   : !FILTER_COMPLEX!
echo Кодеки : !ENC_DESC!

call "%LIB%" :RunJob
exit /b %errorlevel%
