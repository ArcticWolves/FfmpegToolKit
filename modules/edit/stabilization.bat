@echo off
rem ============================================================
rem modules\edit\stabilization.bat
rem Стабилизация видео:
rem   deshake  - один проход, есть в любой сборке FFmpeg;
rem   vidstab  - два прохода (анализ + трансформация), заметно лучше,
rem              есть только в GPL-сборках FFmpeg.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem ============================================================

:MENU
call "%LIB%" :Header "Стабилизация"
echo  Deshake (один проход):
echo   1. Быстрая
echo   2. Стандартная
echo   3. Сильная
echo   4. Свои параметры
echo.
if "%HAS_VIDSTAB%"=="1" (
    echo  VidStab ^(два прохода, лучшее качество^):
    echo   5. Лёгкая
    echo   6. Стандартная
    echo   7. Максимально плавная
) else (
    echo  VidStab: недоступен - нужна GPL-сборка FFmpeg ^(см. Readme.txt^)
)
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите режим"

set "VIDEO_FILTER="
if "%CHOICE%"=="1" set "VIDEO_FILTER=deshake=rx=16:ry=16:search=less:edge=mirror:blocksize=8"
if "%CHOICE%"=="2" set "VIDEO_FILTER=deshake=rx=32:ry=32:edge=mirror:blocksize=8"
if "%CHOICE%"=="3" set "VIDEO_FILTER=deshake=rx=64:ry=64:search=exhaustive:edge=mirror:blocksize=8"
if "%CHOICE%"=="4" goto CUSTOM
if "%CHOICE%"=="0" exit /b 0
if defined VIDEO_FILTER goto RUN_DESHAKE

if not "%HAS_VIDSTAB%"=="1" (call "%LIB%" :InvalidChoice & goto MENU)
set "SHAKY=" & set "SMOOTH="
if "%CHOICE%"=="5" (set "SHAKY=4" & set "SMOOTH=10" & set "OPTZOOM=1")
if "%CHOICE%"=="6" (set "SHAKY=6" & set "SMOOTH=20" & set "OPTZOOM=1")
if "%CHOICE%"=="7" (set "SHAKY=8" & set "SMOOTH=40" & set "OPTZOOM=2")
if not defined SHAKY (call "%LIB%" :InvalidChoice & goto MENU)
goto RUN_VIDSTAB


:CUSTOM
call "%LIB%" :AskInt RX "Макс. смещение по X, пикселей (0-64)" 32 0 64
call "%LIB%" :AskInt RY "Макс. смещение по Y, пикселей (0-64)" 32 0 64
call "%LIB%" :AskPick EDGE "Края: blank, original, clamp, mirror" mirror "blank original clamp mirror"
call "%LIB%" :AskPick SEARCH "Поиск: exhaustive, less" exhaustive "exhaustive less"
set "VIDEO_FILTER=deshake=rx=%RX%:ry=%RY%:edge=%EDGE%:search=%SEARCH%:blocksize=8"

:RUN_DESHAKE
set "OUTPUT_SUFFIX=deshake"
set "JOB_TITLE=Стабилизация (deshake)"
call "%TRANSCODE%"
exit /b 0


rem ------------------------------------------------------------
rem VidStab: проход 1 - анализ движения в .trf, проход 2 - через
rem общий движок (выбор файла, кодеков, запуск).
rem ------------------------------------------------------------
:RUN_VIDSTAB
rem Фиксированное имя: путь попадает в фильтр, апострофы в имени входного
rem файла его бы сломали.
set "TRF=%TRANSFORMS_DIR%\vidstab.trf"
set "TRF_F=%TRF%"
call "%LIB%" :FilterPath TRF_F

call "%LIB%" :Header "VidStab: проход 1 из 2 (анализ)"
set "FF_ARGS=-i "!INPUT_FILE!" -vf "vidstabdetect=result='!TRF_F!':shakiness=%SHAKY%:accuracy=15" -an -f null -"
call "%LIB%" :RunFF
if errorlevel 1 (
    echo [ERROR] Анализ движения не удался.
    pause
    exit /b 1
)

set "VIDEO_FILTER=vidstabtransform=input='!TRF_F!':smoothing=%SMOOTH%:optzoom=%OPTZOOM%:interpol=bicubic,unsharp=5:5:0.8:3:3:0.4"
set "OUTPUT_SUFFIX=vidstab"
set "JOB_TITLE=VidStab: проход 2 из 2"
call "%TRANSCODE%"

if exist "%TRF%" del /q "%TRF%"
exit /b 0
