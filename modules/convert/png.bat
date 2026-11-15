@echo off
rem ============================================================
rem modules\convert\png.bat
rem Профиль изображения: PNG
rem Без потерь, поддерживает прозрачность.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=PNG"
set "OUTPUT_EXT=png"
set "HAS_SETTINGS=0"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v png"
set "IMAGE_DESC=без потерь"
exit /b 0

:SETTINGS
exit /b 0
