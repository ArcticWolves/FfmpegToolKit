@echo off
rem ============================================================
rem modules\edit\subtitles.bat
rem Субтитры: вшить в изображение (burn-in) или добавить отдельной дорожкой.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Субтитры"
echo   1. Вшить внешний файл субтитров (.srt, .ass, .vtt) в изображение
echo   2. Вшить встроенную дорожку субтитров файла
echo   3. Добавить файл субтитров отдельной дорожкой (без перекодирования)
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
if "%CHOICE%"=="0" exit /b 0
if "%CHOICE%"=="1" goto BURN_EXTERNAL
if "%CHOICE%"=="2" goto BURN_EMBEDDED
if "%CHOICE%"=="3" goto MUX
call "%LIB%" :InvalidChoice
exit /b 0

:BURN_EXTERNAL
if not defined HAS_FLT_subtitles (echo [ERROR] Фильтр subtitles ^(libass^) отсутствует в сборке. & pause & exit /b 1)
call "%LIB%" :AskFile SUB "Файл субтитров"
if errorlevel 1 exit /b 0
set "SUB_F=%SUB%"
call "%LIB%" :FilterPath SUB_F
call :AskStyle
set "VIDEO_FILTER=subtitles=filename='!SUB_F!'!STYLE!"
goto RUN_BURN

:BURN_EMBEDDED
if not defined HAS_FLT_subtitles (echo [ERROR] Фильтр subtitles ^(libass^) отсутствует в сборке. & pause & exit /b 1)
if not "%IN_HAS_SUBS%"=="1" (echo [ERROR] В файле нет дорожек субтитров. & pause & exit /b 1)
call "%LIB%" :AskInt SI "Номер дорожки субтитров (0 = первая)" 0 0 99
set "IN_F=%INPUT_FILE%"
call "%LIB%" :FilterPath IN_F
call :AskStyle
set "VIDEO_FILTER=subtitles=filename='!IN_F!':si=%SI%!STYLE!"
goto RUN_BURN

:RUN_BURN
set "OUTPUT_SUFFIX=subs"
set "JOB_TITLE=Вшивание субтитров"
call "%TRANSCODE%"
exit /b 0

:MUX
call "%LIB%" :AskFile SUB "Файл субтитров (.srt, .ass, .vtt)"
if errorlevel 1 exit /b 0
call "%LIB%" :Ask LANG "Язык дорожки (rus, eng, ukr...)" "rus"
set "SUB_CODEC=copy"
if /i "%INPUT_EXT%"=="mp4" set "SUB_CODEC=mov_text"
if /i "%INPUT_EXT%"=="m4v" set "SUB_CODEC=mov_text"
if /i "%INPUT_EXT%"=="mov" set "SUB_CODEC=mov_text"
if /i "%INPUT_EXT%"=="webm" set "SUB_CODEC=webvtt"
set "EXTRA_INPUTS=-i "!SUB!""
set "ENC_FIXED_ARGS=-map 0 -map 1:s -c copy -c:s %SUB_CODEC% -metadata:s:s:0 language=%LANG%"
set "OUTPUT_SUFFIX=subs"
set "JOB_TITLE=Добавление дорожки субтитров"
call "%TRANSCODE%"
exit /b 0

:AskStyle
set "STYLE="
call "%LIB%" :AskInt FS "Размер шрифта для .srt (0 = как в файле)" 0 0 200
if %FS% GTR 0 set "STYLE=:force_style='Fontsize=%FS%'"
exit /b 0
