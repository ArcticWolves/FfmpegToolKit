@echo off
rem ============================================================
rem modules\convert\pam.bat
rem Профиль изображения: PAM
rem Portable Arbitrary Map.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=PAM"
set "OUTPUT_EXT=pam"
set "HAS_SETTINGS=1"
set "P_F=rgba"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v pam -pix_fmt %P_F%"
set "IMAGE_DESC=%P_F%"
exit /b 0

:SETTINGS
echo   rgb24 = цвет, rgba = цвет + прозрачность, gray = серый, ya8 = серый + прозрачность
call "%LIB%" :AskPick P_F "Формат пикселей" %P_F% "rgb24 rgba gray ya8"
exit /b 0
