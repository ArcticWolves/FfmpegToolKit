@echo off
rem ============================================================
rem modules\convert\gif.bat
rem Профиль анимации: GIF
rem Двухэтапная оптимальная палитра в одном проходе FFmpeg.
rem Хуки для convert\_anim.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=GIF"
set "OUTPUT_EXT=gif"
set "HAS_SETTINGS=1"
set "P_COLORS=256"
set "P_DITHER=sierra2_4a"
call "%MODULES_DIR%\convert\_anim.bat" "%~f0"
exit /b %errorlevel%

:ARGS
rem Палитра строится и применяется в одном проходе (split + palettegen
rem + paletteuse) - временный файл палитры не нужен.
set "ANIM_VF_TAIL=split[a][b];[a]palettegen=max_colors=%P_COLORS%:stats_mode=diff[p];[b][p]paletteuse=dither=%P_DITHER%:diff_mode=rectangle"
set "ANIM_ARGS=-loop 0"
set "ANIM_DESC=%P_COLORS% цветов, dither %P_DITHER%"
exit /b 0

:SETTINGS
call "%LIB%" :AskInt P_COLORS "Цветов в палитре 2-256" %P_COLORS% 2 256
echo   sierra2_4a - по умолчанию, floyd_steinberg - мягче,
echo   bayer - узор, меньше размер, none - без смешивания
call "%LIB%" :AskPick P_DITHER "Дизеринг" %P_DITHER% "sierra2_4a sierra2 floyd_steinberg bayer none"
exit /b 0
