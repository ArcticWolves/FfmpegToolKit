@echo off
rem ============================================================
rem modules\edit\crop.bat
rem Кадрирование: по центру, по краям, по пропорциям (9:16, 1:1...), произвольно.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :ProbeInput

:MENU
call "%LIB%" :Header "Кадрирование"
if defined IN_WIDTH echo Исходный размер: !IN_WIDTH!x!IN_HEIGHT!
echo.
echo  По пропорциям (максимальная область по центру):
echo   1. 9:16 (Shorts, Reels, TikTok)   2. 1:1    3. 4:5
echo   4. 16:9                           5. 4:3    6. 21:9
echo.
echo   7. Центральная область W x H
echo   8. Срезать сверху и снизу
echo   9. Срезать слева и справа
echo  10. Произвольная область (W, H, X, Y)
echo  11. Срезать по краям в процентах
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите режим"

set "VIDEO_FILTER="
set "ARW="
if "%CHOICE%"=="1" (set "ARW=9"  & set "ARH=16")
if "%CHOICE%"=="2" (set "ARW=1"  & set "ARH=1")
if "%CHOICE%"=="3" (set "ARW=4"  & set "ARH=5")
if "%CHOICE%"=="4" (set "ARW=16" & set "ARH=9")
if "%CHOICE%"=="5" (set "ARW=4"  & set "ARH=3")
if "%CHOICE%"=="6" (set "ARW=21" & set "ARH=9")
if defined ARW (
    set "VIDEO_FILTER=crop=w='trunc(min(iw,ih*!ARW!/!ARH!)/2)*2':h='trunc(min(ih,iw*!ARH!/!ARW!)/2)*2'"
    set "OUTPUT_SUFFIX=!ARW!x!ARH!"
)
if "%CHOICE%"=="7" (
    call "%LIB%" :AskInt W "Ширина области" 1280 2 16384
    call "%LIB%" :AskInt H "Высота области" 720 2 16384
    set "VIDEO_FILTER=crop=!W!:!H!"
)
if "%CHOICE%"=="8" (
    call "%LIB%" :AskInt PX "Пикселей с каждой стороны" 100 1 8000
    set "VIDEO_FILTER=crop=iw:ih-2*!PX!:0:!PX!"
)
if "%CHOICE%"=="9" (
    call "%LIB%" :AskInt PX "Пикселей с каждой стороны" 100 1 8000
    set "VIDEO_FILTER=crop=iw-2*!PX!:ih:!PX!:0"
)
if "%CHOICE%"=="10" (
    call "%LIB%" :AskInt W "Ширина" 1280 2 16384
    call "%LIB%" :AskInt H "Высота" 720 2 16384
    call "%LIB%" :AskInt X "Смещение X" 0 0 16384
    call "%LIB%" :AskInt Y "Смещение Y" 0 0 16384
    set "VIDEO_FILTER=crop=!W!:!H!:!X!:!Y!"
)
if "%CHOICE%"=="11" (
    call "%LIB%" :AskInt P "Процент с каждого края" 10 1 45
    set "VIDEO_FILTER=crop=trunc(iw*(100-2*!P!)/200)*2:trunc(ih*(100-2*!P!)/200)*2"
)
if "%CHOICE%"=="0" exit /b 0
if not defined VIDEO_FILTER (call "%LIB%" :InvalidChoice & goto MENU)

if not defined OUTPUT_SUFFIX set "OUTPUT_SUFFIX=crop"
set "JOB_TITLE=Кадрирование"
call "%TRANSCODE%"
