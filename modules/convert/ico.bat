@echo off
rem ============================================================
rem modules\convert\ico.bat
rem Профиль изображения: ICO (иконка Windows)
rem Квадратная иконка до 256x256 (PNG внутри ICO).
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=ICO (иконка Windows)"
set "OUTPUT_EXT=ico"
set "HAS_SETTINGS=1"
set "IMAGE_SINGLE_FILE=0"
set "P_S=256"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
set "IMAGE_VF=scale=%P_S%:%P_S%:force_original_aspect_ratio=decrease:flags=lanczos,pad=%P_S%:%P_S%:-1:-1:color=black@0,format=rgba"
set "IMAGE_ARGS=-c:v png"
set "IMAGE_DESC=%P_S%x%P_S%, прозрачные поля"
exit /b 0

:SETTINGS
call "%LIB%" :AskPick P_S "Размер: 16, 24, 32, 48, 64, 128, 256" %P_S% "16 24 32 48 64 128 256"
exit /b 0
