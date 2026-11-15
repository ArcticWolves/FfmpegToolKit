@echo off
rem ============================================================
rem modules\edit\volume.bat
rem Громкость: усиление/ослабление, выравнивание, лимитер.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 1)
call "%LIB%" :Header "Громкость"
echo   1. Изменить на N децибел (+6 = громче, -6 = тише)
echo   2. Выровнять громкость фраз (dynaudnorm, для речи)
echo   3. Громче без перегрузки (усиление + лимитер)
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
set "AUDIO_FILTER="
if "%CHOICE%"=="1" (
    call "%LIB%" :AskNum DB "Децибел" 6
    set "AUDIO_FILTER=volume=!DB!dB"
)
if "%CHOICE%"=="2" set "AUDIO_FILTER=dynaudnorm=f=250:g=15"
if "%CHOICE%"=="3" (
    call "%LIB%" :AskNum DB "Усиление, децибел" 6
    set "AUDIO_FILTER=volume=!DB!dB,alimiter=limit=0.95:level=disabled"
)
if "%CHOICE%"=="0" exit /b 0
if not defined AUDIO_FILTER (call "%LIB%" :InvalidChoice & exit /b 0)
set "OUTPUT_SUFFIX=volume"
set "JOB_TITLE=Громкость"
call "%TRANSCODE%"
