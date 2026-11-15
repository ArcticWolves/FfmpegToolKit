@echo off
rem ============================================================
rem modules\convert\_anim.bat
rem Движок: фрагмент видео -> анимированное изображение
rem (GIF, анимированный WebP, APNG).
rem
rem Вызов из профиля:  call "%MODULES_DIR%\convert\_anim.bat" "%~f0"
rem
rem Общие параметры: начало, длительность, FPS, ширина.
rem Профиль задаёт FORMAT_TITLE, OUTPUT_EXT, HAS_SETTINGS и хуки:
rem   args      -> ANIM_VF_TAIL (продолжение фильтра после fps/scale),
rem                ANIM_ARGS (кодек и опции), ANIM_DESC
rem   settings  -> диалог параметров формата
rem ============================================================

set "PROFILE=%~1"
call "%LIB%" :RequireInput
if errorlevel 1 exit /b 1
call "%LIB%" :ProbeInput
if not "%IN_HAS_VIDEO%"=="1" (echo [ERROR] Во входном файле нет видео. & pause & exit /b 1)

set "A_START=0"
set "A_DUR=5"
set "A_FPS=15"
set "A_WIDTH=480"

:MENU
set "ANIM_VF_TAIL=" & set "ANIM_ARGS=" & set "ANIM_DESC="
call "%PROFILE%" args
call "%LIB%" :Header "%FORMAT_TITLE%"
echo Вход: !INPUT_FILE!
if defined IN_DURATION echo Длительность видео: !IN_DURATION! с
echo.
echo  1. Начало        : %A_START%
echo  2. Длительность  : %A_DUR% с  (0 = до конца)
echo  3. Кадров/сек    : %A_FPS%
echo  4. Ширина        : %A_WIDTH%  (0 = исходная)
if "%HAS_SETTINGS%"=="1" echo  5. Параметры     : !ANIM_DESC!
echo.
echo  Enter. Создать
echo  0.     Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if not defined CHOICE goto RUN
if "%CHOICE%"=="0" exit /b 0
if "%CHOICE%"=="1" (call "%LIB%" :AskTime A_START "Начало" %A_START% & goto MENU)
if "%CHOICE%"=="2" (call "%LIB%" :AskNum A_DUR "Длительность, секунд" %A_DUR% & goto MENU)
if "%CHOICE%"=="3" (call "%LIB%" :AskInt A_FPS "Кадров в секунду" %A_FPS% 1 60 & goto MENU)
if "%CHOICE%"=="4" (call "%LIB%" :AskInt A_WIDTH "Ширина, пикселей" %A_WIDTH% 0 7680 & goto MENU)
if "%CHOICE%"=="5" if "%HAS_SETTINGS%"=="1" (call "%PROFILE%" settings & goto MENU)
call "%LIB%" :InvalidChoice
goto MENU

:RUN
set "OUTPUT_SUFFIX=anim"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MENU

set "VF=fps=%A_FPS%"
if not "%A_WIDTH%"=="0" set "VF=!VF!,scale=%A_WIDTH%:-1:flags=lanczos"
if defined ANIM_VF_TAIL set "VF=!VF!,!ANIM_VF_TAIL!"

set "FF_ARGS=-ss %A_START%"
if not "%A_DUR%"=="0" set "FF_ARGS=!FF_ARGS! -t %A_DUR%"
set "FF_ARGS=!FF_ARGS! -i "!INPUT_FILE!" -vf "!VF!" !ANIM_ARGS! -an "!OUTPUT_FILE!""

call "%LIB%" :RunJob
goto MENU
