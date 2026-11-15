@echo off
rem ============================================================
rem modules\edit\speed.bat
rem Изменение скорости воспроизведения (видео + аудио с сохранением тона).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
call "%LIB%" :Header "Изменение скорости"
echo  1. 0.25x   2. 0.5x   3. 0.75x   4. 1.25x
echo  5. 1.5x    6. 2x     7. 4x      8. Своё значение
echo  0. Назад
echo.
call "%LIB%" :AskChoice "Выберите скорость"
set "SPEED="
if "%CHOICE%"=="1" set "SPEED=0.25"
if "%CHOICE%"=="2" set "SPEED=0.5"
if "%CHOICE%"=="3" set "SPEED=0.75"
if "%CHOICE%"=="4" set "SPEED=1.25"
if "%CHOICE%"=="5" set "SPEED=1.5"
if "%CHOICE%"=="6" set "SPEED=2"
if "%CHOICE%"=="7" set "SPEED=4"
if "%CHOICE%"=="8" call "%LIB%" :AskNum SPEED "Коэффициент (0.1 - 100)" 1.5
if "%CHOICE%"=="0" exit /b 0
if not defined SPEED (call "%LIB%" :InvalidChoice & exit /b 0)

call "%LIB%" :ToMilli MILLI "%SPEED%"
if %MILLI% LSS 100 (echo [ERROR] Минимум 0.1 & pause & exit /b 0)
if %MILLI% GTR 100000 (echo [ERROR] Максимум 100 & pause & exit /b 0)

rem Видео: новые метки времени
if "%IN_HAS_VIDEO%"=="1" set "VIDEO_FILTER=setpts=PTS/%SPEED%"

rem Аудио: atempo принимает 0.5..100, для меньших значений - цепочка
if "%IN_HAS_AUDIO%"=="1" (
    set "AUDIO_FILTER="
    set "REST=%MILLI%"
    call :BuildAtempo
)

set "OUTPUT_SUFFIX=speed_%SPEED%x"
set "JOB_TITLE=Скорость %SPEED%x"
call "%TRANSCODE%"
exit /b %errorlevel%

:BuildAtempo
if %REST% GEQ 500 goto BuildAtempoLast
set "AUDIO_FILTER=%AUDIO_FILTER%atempo=0.5,"
set /a REST*=2
goto BuildAtempo
:BuildAtempoLast
call "%LIB%" :FromMilli _t %REST%
set "AUDIO_FILTER=%AUDIO_FILTER%atempo=%_t%"
exit /b 0
