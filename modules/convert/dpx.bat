@echo off
rem ============================================================
rem modules\convert\dpx.bat
rem Профиль изображения: DPX
rem Digital Picture Exchange (кино, цветокоррекция).
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=DPX"
set "OUTPUT_EXT=dpx"
set "HAS_SETTINGS=1"
set "P_F=gbrp10le"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v dpx -pix_fmt %P_F%"
set "IMAGE_DESC=%P_F%"
exit /b 0

:SETTINGS
echo   rgb24 = 8 бит, gbrp10le = 10 бит, rgb48le = 16 бит
call "%LIB%" :AskPick P_F "Формат пикселей" %P_F% "rgb24 gbrp10le rgb48le"
exit /b 0
