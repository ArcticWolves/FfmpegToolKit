@echo off
rem ============================================================
rem modules\convert\apng.bat
rem Профиль анимации: APNG (анимированный PNG)
rem Полноцветная анимация с прозрачностью, без потерь.
rem Хуки для convert\_anim.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=APNG (анимированный PNG)"
set "OUTPUT_EXT=apng"
set "HAS_SETTINGS=1"
set "P_PLAYS=0"
call "%MODULES_DIR%\convert\_anim.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "ANIM_ARGS=-c:v apng -plays %P_PLAYS% -f apng"
set "ANIM_DESC=повторов %P_PLAYS% (0 = бесконечно)"
exit /b 0

:SETTINGS
call "%LIB%" :AskInt P_PLAYS "Количество повторов (0 = бесконечно)" %P_PLAYS% 0 1000
exit /b 0
