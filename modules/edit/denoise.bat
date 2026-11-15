@echo off
rem ============================================================
rem modules\edit\denoise.bat
rem Шумоподавление видео (nlmeans / atadenoise / hqdn3d).
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

call "%LIB%" :Header "Шумоподавление видео"
echo   1. Лёгкое     2. Среднее     3. Сильное
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Сила"
if "%CHOICE%"=="0" exit /b 0
set "LVL="
for %%L in (1 2 3) do if "%CHOICE%"=="%%L" set "LVL=%%L"
if not defined LVL (call "%LIB%" :InvalidChoice & exit /b 0)

echo.
echo Метод:
if defined HAS_FLT_hqdn3d (
    echo  1. hqdn3d    - быстрый, хороший баланс   [Enter]
) else (
    echo  1. hqdn3d    - недоступен ^(нужна GPL-сборка^)
)
echo  2. atadenoise - быстрый временной
echo  3. nlmeans    - лучшее качество, очень медленно
call "%LIB%" :AskChoice "Метод"
set "M=%CHOICE%"
if not defined M set "M=1"
if "%M%"=="1" if not defined HAS_FLT_hqdn3d set "M=2"

if "%M%"=="1" (
    if "%LVL%"=="1" set "VIDEO_FILTER=hqdn3d=2:1.5:3:3"
    if "%LVL%"=="2" set "VIDEO_FILTER=hqdn3d=4:3:6:4.5"
    if "%LVL%"=="3" set "VIDEO_FILTER=hqdn3d=8:6:12:9"
)
if "%M%"=="2" (
    if "%LVL%"=="1" set "VIDEO_FILTER=atadenoise=0a=0.02:0b=0.04:1a=0.02:1b=0.04:2a=0.02:2b=0.04"
    if "%LVL%"=="2" set "VIDEO_FILTER=atadenoise"
    if "%LVL%"=="3" set "VIDEO_FILTER=atadenoise=0a=0.04:0b=0.08:1a=0.04:1b=0.08:2a=0.04:2b=0.08:s=15"
)
if "%M%"=="3" (
    if "%LVL%"=="1" set "VIDEO_FILTER=nlmeans=s=1.5"
    if "%LVL%"=="2" set "VIDEO_FILTER=nlmeans=s=3"
    if "%LVL%"=="3" set "VIDEO_FILTER=nlmeans=s=6"
)
if not defined VIDEO_FILTER (call "%LIB%" :InvalidChoice & exit /b 0)
set "OUTPUT_SUFFIX=denoise"
set "JOB_TITLE=Шумоподавление"
call "%TRANSCODE%"
