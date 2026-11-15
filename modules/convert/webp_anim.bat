@echo off
rem ============================================================
rem modules\convert\webp_anim.bat
rem Профиль анимации: Анимированный WebP
rem Обычно в 2-5 раз меньше GIF при лучшем качестве.
rem Хуки для convert\_anim.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=Анимированный WebP"
set "OUTPUT_EXT=webp"
set "HAS_SETTINGS=1"
set "P_Q=75"
set "P_LOSSLESS=0"
call "%MODULES_DIR%\convert\_anim.bat" "%~f0"
exit /b %errorlevel%

:ARGS
if "%P_LOSSLESS%"=="1" (
    set "ANIM_ARGS=-c:v libwebp -lossless 1 -loop 0"
    set "ANIM_DESC=без потерь"
) else (
    set "ANIM_ARGS=-c:v libwebp -quality %P_Q% -compression_level 6 -loop 0"
    set "ANIM_DESC=качество %P_Q%"
)
exit /b 0

:SETTINGS
call "%LIB%" :AskYN "Без потерь?" N
if errorlevel 1 (set "P_LOSSLESS=0") else (set "P_LOSSLESS=1")
if "%P_LOSSLESS%"=="0" call "%LIB%" :AskInt P_Q "Качество 0-100" %P_Q% 0 100
exit /b 0
