@echo off
rem ============================================================
rem modules\convert\jxl.bat
rem Профиль изображения: JPEG XL
rem JPEG XL через libjxl.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=JPEG XL"
set "OUTPUT_EXT=jxl"
set "HAS_SETTINGS=1"
set "P_D=1"
set "P_E=7"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v libjxl -distance %P_D% -effort %P_E%"
set "IMAGE_DESC=distance %P_D% (0 = без потерь), effort %P_E%"
exit /b 0

:SETTINGS
call "%LIB%" :AskNum P_D "Distance 0-15, 0 = без потерь, 1 = визуально без потерь" %P_D%
call "%LIB%" :AskInt P_E "Effort 1-9, больше = медленнее и меньше" %P_E% 1 9
exit /b 0
