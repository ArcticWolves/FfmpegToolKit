@echo off
rem ============================================================
rem modules\convert\hdr.bat
rem Профиль изображения: Radiance HDR
rem Radiance RGBE (.hdr).
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=Radiance HDR"
set "OUTPUT_EXT=hdr"
set "HAS_SETTINGS=0"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v hdr -pix_fmt gbrpf32le"
set "IMAGE_DESC=RGBE float"
exit /b 0

:SETTINGS
exit /b 0
