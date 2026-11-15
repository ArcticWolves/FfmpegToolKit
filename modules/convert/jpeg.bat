@echo off
rem ============================================================
rem modules\convert\jpeg.bat
rem Профиль изображения: JPEG
rem Сжатие с потерями.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=JPEG"
set "OUTPUT_EXT=jpg"
set "HAS_SETTINGS=1"
set "P_Q=2"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v mjpeg -q:v %P_Q% -pix_fmt yuvj444p"
set "IMAGE_DESC=качество q=%P_Q% (2 = лучшее)"
exit /b 0

:SETTINGS
call "%LIB%" :AskInt P_Q "Качество 2-31, меньше = лучше" %P_Q% 2 31
exit /b 0
