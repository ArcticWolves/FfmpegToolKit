@echo off
rem ============================================================
rem modules\edit\deinterlace.bat
rem Деинтерлейсинг (bwdif / yadif) для видео с камер, ТВ, DVD.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Деинтерлейсинг"
echo   1. bwdif, частота кадров сохраняется         [Enter]
echo   2. bwdif, удвоенная частота (плавнее: 25i - 50p)
echo   3. yadif, частота кадров сохраняется
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите вариант"
set "VIDEO_FILTER=bwdif=mode=send_frame:deint=interlaced"
if "%CHOICE%"=="2" set "VIDEO_FILTER=bwdif=mode=send_field:deint=interlaced"
if "%CHOICE%"=="3" set "VIDEO_FILTER=yadif=mode=send_frame:deint=interlaced"
if "%CHOICE%"=="0" exit /b 0
set "OUTPUT_SUFFIX=deint"
set "JOB_TITLE=Деинтерлейсинг"
call "%TRANSCODE%"
