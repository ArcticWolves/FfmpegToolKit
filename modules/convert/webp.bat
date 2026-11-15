@echo off
rem ============================================================
rem modules\convert\webp.bat
rem Профиль изображения: WebP
rem Современный формат для веба (libwebp).
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=WebP"
set "OUTPUT_EXT=webp"
set "HAS_SETTINGS=1"
set "P_Q=90"
set "P_LOSSLESS=0"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
if "%P_LOSSLESS%"=="1" (
    set "IMAGE_ARGS=-c:v libwebp -lossless 1 -compression_level 6"
    set "IMAGE_DESC=без потерь"
) else (
    set "IMAGE_ARGS=-c:v libwebp -quality %P_Q% -compression_level 6"
    set "IMAGE_DESC=качество %P_Q%"
)
exit /b 0

:SETTINGS
call "%LIB%" :AskYN "Без потерь?" N
if errorlevel 1 (set "P_LOSSLESS=0") else (set "P_LOSSLESS=1")
if "%P_LOSSLESS%"=="0" call "%LIB%" :AskInt P_Q "Качество 0-100" %P_Q% 0 100
exit /b 0
