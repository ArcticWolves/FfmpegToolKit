@echo off
rem ============================================================
rem modules\convert\tiff.bat
rem Профиль изображения: TIFF
rem TIFF для печати и архива.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=TIFF"
set "OUTPUT_EXT=tiff"
set "HAS_SETTINGS=1"
set "P_C=lzw"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_ARGS=-c:v tiff -compression_algo %P_C%"
set "IMAGE_DESC=сжатие %P_C%"
exit /b 0

:SETTINGS
call "%LIB%" :AskPick P_C "Сжатие: raw, lzw, deflate, packbits" %P_C% "raw lzw deflate packbits"
exit /b 0
