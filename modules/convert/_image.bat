@echo off
rem ============================================================
rem modules\convert\_image.bat
rem Движок: один кадр из видео (или картинка) -> файл изображения.
rem
rem Вызов из профиля:  call "%MODULES_DIR%\convert\_image.bat" "%~f0"
rem
rem Профиль задаёт:
rem   FORMAT_TITLE, OUTPUT_EXT
rem   HAS_SETTINGS=1       есть экран параметров формата
rem и реализует хуки (вызываются как  call профиль хук):
rem   args      -> IMAGE_ARGS (кодек и опции), IMAGE_VF (фильтр,
rem                необязательно), IMAGE_DESC (описание параметров)
rem   settings  -> диалог изменения параметров
rem
rem Необязательно: IMAGE_SINGLE_FILE=0 для форматов, которые пишет не
rem муксер image2 (ico, avif) - тогда не добавляется -update 1.
rem ============================================================

set "PROFILE=%~1"
call "%LIB%" :RequireInput
if errorlevel 1 exit /b 1
call "%LIB%" :ProbeInput
set "TIMECODE=0"

:MENU
set "IMAGE_ARGS=" & set "IMAGE_VF=" & set "IMAGE_DESC="
call "%PROFILE%" args
call "%LIB%" :Header "%FORMAT_TITLE%"
echo Вход     : !INPUT_FILE!
if defined IN_WIDTH echo Размер   : !IN_WIDTH!x!IN_HEIGHT!
if defined IN_DURATION echo Длит.    : !IN_DURATION! с
echo Кадр     : %TIMECODE%
if defined IMAGE_DESC echo Параметры: !IMAGE_DESC!
echo.
echo  1. Время кадра (для видео)
if "%HAS_SETTINGS%"=="1" echo  2. Параметры формата
echo.
echo  Enter. Сохранить
echo  0.     Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if not defined CHOICE goto RUN
if "%CHOICE%"=="0" exit /b 0
if "%CHOICE%"=="1" (
    call "%LIB%" :AskTime TIMECODE "Время кадра (00:01:23.5 или секунды)" %TIMECODE%
    goto MENU
)
if "%CHOICE%"=="2" if "%HAS_SETTINGS%"=="1" (
    call "%PROFILE%" settings
    goto MENU
)
call "%LIB%" :InvalidChoice
goto MENU

:RUN
set "OUTPUT_SUFFIX=frame"
if "%IN_DURATION%"=="" set "OUTPUT_SUFFIX=img"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MENU

set "FF_ARGS=-ss %TIMECODE% -i "!INPUT_FILE!" -frames:v 1"
if defined IMAGE_VF set "FF_ARGS=!FF_ARGS! -vf "!IMAGE_VF!""
set "FF_ARGS=!FF_ARGS! !IMAGE_ARGS!"
if not "%IMAGE_SINGLE_FILE%"=="0" set "FF_ARGS=!FF_ARGS! -update 1"
set "FF_ARGS=!FF_ARGS! "!OUTPUT_FILE!""

call "%LIB%" :RunJob
goto MENU
