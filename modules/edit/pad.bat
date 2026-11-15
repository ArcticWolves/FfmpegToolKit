@echo off
rem ============================================================
rem modules\edit\pad.bat
rem Приведение к нужным пропорциям: поля цветом или размытым фоном.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Поля до нужного размера"
echo Видео вписывается в кадр без обрезки, остаток заполняется.
echo.
echo   1. 1080x1920 (9:16, Shorts / Reels)
echo   2. 1920x1080 (16:9)
echo   3. 1080x1080 (1:1)
echo   4. 1080x1350 (4:5)
echo   5. Свой размер
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Размер кадра"
set "W=" & set "H="
if "%CHOICE%"=="1" (set "W=1080" & set "H=1920")
if "%CHOICE%"=="2" (set "W=1920" & set "H=1080")
if "%CHOICE%"=="3" (set "W=1080" & set "H=1080")
if "%CHOICE%"=="4" (set "W=1080" & set "H=1350")
if "%CHOICE%"=="5" (
    call "%LIB%" :AskInt W "Ширина (чётная)" 1080 16 16384
    call "%LIB%" :AskInt H "Высота (чётная)" 1920 16 16384
)
if "%CHOICE%"=="0" exit /b 0
if not defined W (call "%LIB%" :InvalidChoice & exit /b 0)

echo.
echo Заполнение:
echo  1. Размытая копия видео   [Enter]
echo  2. Чёрный
echo  3. Белый
echo  4. Свой цвет (имя или #RRGGBB)
call "%LIB%" :AskChoice "Вариант"
set "COLOR="
if "%CHOICE%"=="2" set "COLOR=black"
if "%CHOICE%"=="3" set "COLOR=white"
if "%CHOICE%"=="4" call "%LIB%" :Ask COLOR "Цвет" "gray"

set "FIT=scale=%W%:%H%:force_original_aspect_ratio=decrease"
if defined COLOR (
    set "VIDEO_FILTER=!FIT!,pad=%W%:%H%:-1:-1:color=!COLOR!,setsar=1"
) else (
    rem Фон: растянуть с обрезкой и размыть; поверх - вписанное видео
    set "VIDEO_FILTER=split[bg][fg];[bg]scale=%W%:%H%:force_original_aspect_ratio=increase,crop=%W%:%H%,gblur=sigma=40[bgb];[fg]!FIT![fgs];[bgb][fgs]overlay=(W-w)/2:(H-h)/2,setsar=1"
)
set "OUTPUT_SUFFIX=%W%x%H%"
set "JOB_TITLE=Поля"
call "%TRANSCODE%"
