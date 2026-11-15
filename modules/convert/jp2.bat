@echo off
rem ============================================================
rem modules\convert\jp2.bat
rem Профиль изображения: JPEG 2000
rem JPEG 2000 (встроенный энкодер).
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=JPEG 2000"
set "OUTPUT_EXT=jp2"
set "HAS_SETTINGS=1"
set "P_Q=3"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v jpeg2000 -q:v %P_Q%"
set "IMAGE_DESC=качество q=%P_Q% (1 = лучшее)"
exit /b 0

:SETTINGS
call "%LIB%" :AskInt P_Q "Качество 1-31, меньше = лучше" %P_Q% 1 31
exit /b 0
