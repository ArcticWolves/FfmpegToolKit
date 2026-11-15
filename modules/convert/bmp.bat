@echo off
rem ============================================================
rem modules\convert\bmp.bat
rem Профиль изображения: BMP
rem Несжатый BMP.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=BMP"
set "OUTPUT_EXT=bmp"
set "HAS_SETTINGS=0"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v bmp"
set "IMAGE_DESC=без сжатия"
exit /b 0

:SETTINGS
exit /b 0
