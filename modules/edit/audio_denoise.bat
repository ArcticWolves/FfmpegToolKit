@echo off
rem ============================================================
rem modules\edit\audio_denoise.bat
rem Шумоподавление звука: фон, гул, шипение; очистка голоса.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 1)
call "%LIB%" :Header "Шумоподавление аудио"
echo   1. Лёгкое (afftdn)
echo   2. Сильное (afftdn)
echo   3. Нелокальные средние (anlmdn, медленно, бережно к голосу)
echo   4. Очистка голоса: срез гула и верхов + шумоподавление
echo   5. Убрать гул 50 Гц (сеть)
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
set "AUDIO_FILTER="
if "%CHOICE%"=="1" set "AUDIO_FILTER=afftdn=nr=12:nf=-50"
if "%CHOICE%"=="2" set "AUDIO_FILTER=afftdn=nr=25:nf=-40:tn=1"
if "%CHOICE%"=="3" set "AUDIO_FILTER=anlmdn=s=0.0005"
if "%CHOICE%"=="4" set "AUDIO_FILTER=highpass=f=80,lowpass=f=12000,afftdn=nr=15:nf=-45"
if "%CHOICE%"=="5" set "AUDIO_FILTER=bandreject=f=50:width_type=q:w=10,bandreject=f=100:width_type=q:w=10,bandreject=f=150:width_type=q:w=10"
if "%CHOICE%"=="0" exit /b 0
if not defined AUDIO_FILTER (call "%LIB%" :InvalidChoice & exit /b 0)
set "OUTPUT_SUFFIX=clean"
set "JOB_TITLE=Шумоподавление аудио"
call "%TRANSCODE%"
