@echo off
rem ============================================================
rem modules\convert\qoi.bat
rem Профиль изображения: QOI
rem Quite OK Image: простой быстрый формат без потерь.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=QOI"
set "OUTPUT_EXT=qoi"
set "HAS_SETTINGS=0"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v qoi"
set "IMAGE_DESC=без потерь, быстрый"
exit /b 0

:SETTINGS
exit /b 0
