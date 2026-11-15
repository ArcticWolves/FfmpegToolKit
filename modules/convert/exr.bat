@echo off
rem ============================================================
rem modules\convert\exr.bat
rem Профиль изображения: OpenEXR
rem HDR-изображение для VFX и композитинга.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=OpenEXR"
set "OUTPUT_EXT=exr"
set "HAS_SETTINGS=1"
set "P_C=zip16"
set "P_T=half"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v exr -compression %P_C% -format %P_T% -pix_fmt gbrpf32le"
set "IMAGE_DESC=сжатие %P_C%, %P_T%"
exit /b 0

:SETTINGS
call "%LIB%" :AskPick P_C "Сжатие: none, rle, zip1, zip16" %P_C% "none rle zip1 zip16"
call "%LIB%" :AskPick P_T "Тип: half (16 бит), float (32 бит)" %P_T% "half float"
exit /b 0
