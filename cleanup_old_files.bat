@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem ============================================================
rem cleanup_old_files.bat
rem Одноразовый скрипт: удаляет файлы старой версии ToolKit,
rem которые больше не используются после рефакторинга, и затем
rem удаляет сам себя. Если проект под git, вместо него можно
rem выполнить команду git rm (см. в конце файла).
rem ============================================================

cd /d "%~dp0"

set FILES=^
 "ffplay.bat"^
 "history.log"^
 "modules\ffmpeg.bat"^
 "modules\presets.bat"^
 "modules\convert\dds.bat"^
 "modules\convert\psd.bat"^
 "modules\convert\cin.bat"^
 "modules\convert\pbm.bat"^
 "modules\convert\pgm.bat"^
 "modules\convert\ppm.bat"^
 "modules\edit\filters\color_equalizer.bat"^
 "modules\edit\filters\color_hue.bat"^
 "modules\edit\filters\lut.bat"^
 "modules\edit\stabilizators\deshake.bat"^
 "modules\edit\stabilizators\vidstab.bat"^
 "modules\edit\stabilizators\vidstabdetect.bat"^
 "modules\edit\stabilizators\vidstabtransform.bat"^
 "selectors\select_video_codec.bat"^
 "selectors\select_audio_codec.bat"^
 "selectors\select_edit_encode_profile.bat"^
 "presets\stabilizators\deshake_presset.bat"

set DIRS=^
 "modules\edit\filters"^
 "modules\edit\stabilizators"^
 "modules\codecs\audio\video"^
 "presets\stabilizators"^
 "presets\color_corections"^
 "presets"^
 "temp\palettes"

echo Будут удалены устаревшие файлы старой версии:
for %%F in (%FILES%) do if exist %%F echo   %%~F
echo и пустые папки:
for %%D in (%DIRS%) do if exist %%D echo   %%~D
echo.
set "ANSWER="
set /p "ANSWER=Удалить? (Y/N): "
if /i not "%ANSWER%"=="Y" (
    echo Отменено.
    pause
    exit /b 0
)

for %%F in (%FILES%) do if exist %%F del /q %%F
for %%D in (%DIRS%) do if exist %%D rd %%D 2>nul

echo Готово.
pause
(goto) 2>nul & del "%~f0"

rem Альтернатива для git (одной командой из папки проекта):
rem   git rm ffplay.bat modules/ffmpeg.bat modules/presets.bat
rem     modules/convert/{dds,psd,cin,pbm,pgm,ppm}.bat
rem     -r modules/edit/filters modules/edit/stabilizators presets
rem     selectors/select_video_codec.bat selectors/select_audio_codec.bat
rem     selectors/select_edit_encode_profile.bat
