@echo off
rem ============================================================
rem modules\edit\concat.bat
rem Склейка нескольких файлов.
rem   Без перекодирования (concat demuxer) - мгновенно, но все файлы
rem   должны иметь одинаковые кодеки, разрешение и параметры звука.
rem   С перекодированием (фильтр concat) - любые файлы: разрешение
rem   приводится к первому файлу, звук - к 48 кГц стерео.
rem ============================================================

set "LIST_FILE=%TEMP_DIR%\concat_list.txt"
set "N=0"

:MENU
call "%LIB%" :Header "Склейка файлов"
echo Файлов в списке: %N%
for /L %%I in (1,1,%N%) do call :ShowItem %%I
echo.
echo   1. Добавить все медиафайлы из папки input (по имени)
echo   2. Добавить файл
echo   3. Очистить список
echo   4. Склеить без перекодирования (быстро)
echo   5. Склеить с перекодированием (любые файлы)
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if "%CHOICE%"=="1" goto ADD_ALL
if "%CHOICE%"=="2" goto ADD_ONE
if "%CHOICE%"=="3" (set "N=0" & goto MENU)
if "%CHOICE%"=="4" goto RUN_COPY
if "%CHOICE%"=="5" goto RUN_REENCODE
if "%CHOICE%"=="0" exit /b 0
call "%LIB%" :InvalidChoice
goto MENU

:ADD_ALL
for /f "delims=" %%F in ('dir /b /a-d /on "%INPUT_DIR%" 2^>nul') do (
    call "%LIB%" :IsMediaFile "%%F"
    if not errorlevel 1 (
        set /a N+=1
        set "F_!N!=%INPUT_DIR%\%%F"
    )
)
goto MENU

:ADD_ONE
set "INPUT_TITLE=Добавить файл в склейку"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto MENU
set /a N+=1
set "F_%N%=%INPUT_FILE%"
goto MENU

:CHECK_COUNT
call "%LIB%" :ResetJob
if %N% LSS 2 (
    echo.
    echo [ERROR] Нужно минимум два файла.
    pause
    exit /b 1
)
set "INPUT_FILE=%F_1%"
for %%F in ("%F_1%") do (set "INPUT_NAME=%%~nF" & set "INPUT_EXT=%%~xF")
set "INPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_BASE=%INPUT_NAME%"
set "OUTPUT_SUFFIX=concat"
exit /b 0


rem ------------------------------------------------------------
rem Без перекодирования: список для concat demuxer.
rem Апостроф в пути экранируется как '\''
rem ------------------------------------------------------------
:RUN_COPY
call :CHECK_COUNT
if errorlevel 1 goto MENU
type nul > "%LIST_FILE%"
for /L %%I in (1,1,%N%) do call :ShowItem
call set "_p=%%F_%1%%"
echo   %1. !_p!
exit /b 0

:WriteListLine %%I
set "INPUT_FILE=%LIST_FILE%"
set "INPUT_OPTS=-f concat -safe 0"
set "ENC_FIXED_ARGS=-map 0 -c copy"
set "JOB_TITLE=Склейка без перекодирования"
call "%TRANSCODE%"
goto MENU


rem ------------------------------------------------------------
rem С перекодированием: фильтр concat. Каждый вход приводится к
rem размеру первого файла (с полями), 30 fps и 48 кГц стерео.
rem Если хотя бы у одного файла нет звука - склеивается только видео.
rem ------------------------------------------------------------
:RUN_REENCODE
call :CHECK_COUNT
if errorlevel 1 goto MENU
call "%LIB%" :ProbeInput
if not defined IN_WIDTH (
    echo [ERROR] В первом файле нет видео.
    pause
    goto MENU
)
set "W=%IN_WIDTH%"
set "H=%IN_HEIGHT%"
set /a "W=W/2*2, H=H/2*2"

set "ALL_AUDIO=1"
for /L %%I in (1,1,%N%) do call :CheckAudio %%I

set "EXTRA_INPUTS="
set "FC="
set "CAT="
set /a "LAST=N-1"
for /L %%I in (0,1,%LAST%) do call :AddInput %%I
if "%ALL_AUDIO%"=="1" (
    set "FILTER_COMPLEX=!FC!!CAT!concat=n=%N%:v=1:a=1[v][a]"
    set "MAP_ARGS=-map "[v]" -map "[a]""
) else (
    echo [WARN] Не у всех файлов есть звук - результат будет без звука.
    pause
    set "FILTER_COMPLEX=!FC!!CAT!concat=n=%N%:v=1:a=0[v]"
    set "MAP_ARGS=-map "[v]""
    set "ENC_NO_AUDIO=1"
)
set "ENC_VIDEO_NO_COPY=1"
set "ENC_AUDIO_NO_COPY=1"
set "JOB_TITLE=Склейка с перекодированием"
call "%TRANSCODE%"
goto MENU


rem ------------------------------------------------------------
rem Вспомогательные подпрограммы (индексные переменные F_1..F_N)
rem ------------------------------------------------------------
:ShowItem
call set "_p=%%F_%1%%"
echo   %1. !_p!
exit /b 0

:WriteListLine
call set "_p=%%F_%1%%"
set "_p=!_p:'='\''!"
>> "%LIST_FILE%" echo file '!_p!'
exit /b 0

:CheckAudio
call set "_p=%%F_%1%%"
call "%LIB%" :Probe _a "-select_streams a:0 -show_entries stream=codec_name" "%_p%"
if not defined _a set "ALL_AUDIO=0"
exit /b 0

:AddInput
set /a "_j=%1+1"
call set "_p=%%F_%_j%%%"
if %1 GTR 0 set "EXTRA_INPUTS=!EXTRA_INPUTS! -i "!_p!""
set "FC=!FC![%1:v]scale=%W%:%H%:force_original_aspect_ratio=decrease,pad=%W%:%H%:-1:-1,setsar=1,fps=30,format=yuv420p[v%1];"
if "%ALL_AUDIO%"=="1" (
    set "FC=!FC![%1:a]aresample=48000,aformat=channel_layouts=stereo[a%1];"
    set "CAT=!CAT![v%1][a%1]"
) else (
    set "CAT=!CAT![v%1]"
)
exit /b 0
