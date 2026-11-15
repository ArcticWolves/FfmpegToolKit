@echo off
rem ============================================================
rem modules\convert\avif.bat
rem Профиль изображения: AVIF
rem AV1 Image File Format через libaom.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=AVIF"
set "OUTPUT_EXT=avif"
set "HAS_SETTINGS=1"
set "IMAGE_SINGLE_FILE=0"
set "P_Q=24"
set "P_S=4"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v libaom-av1 -still-picture 1 -crf %P_Q% -b:v 0 -cpu-used %P_S% -pix_fmt yuv420p"
set "IMAGE_DESC=CRF %P_Q%, cpu-used %P_S%"
exit /b 0

:SETTINGS
call "%LIB%" :AskInt P_Q "CRF 0-63, меньше = лучше" %P_Q% 0 63
call "%LIB%" :AskInt P_S "cpu-used 0-8, больше = быстрее" %P_S% 0 8
exit /b 0
