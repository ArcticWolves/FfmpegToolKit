@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert.bat
rem
rem Раздел "Конвертация".
rem
rem Архитектурная роль:
rem   Controller.
rem
rem Подмодули находятся в:
rem   modules\convert\
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                      Конвертация
echo ============================================================
echo.
echo ---------------- Видео ----------------
echo  1. MP4  (H.264 + AAC)
echo  2. MP4  (H.265 + AAC)
echo  3. WebM (VP9 + Opus)
echo  4. OGV  (Theora + Vorbis)
echo  5. GIF
echo.
echo ---------------- Аудио ----------------
echo  6. MP3
echo  7. WAV
echo  8. FLAC
echo  9. Opus
echo 10. AAC (M4A)
echo 11. OGG Vorbis
echo.
echo ---------------- Изображения ----------
echo 12. PNG
echo 13. JPEG
echo 14. WebP
echo 15. AVIF
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите формат: "

if "%CHOICE%"=="1"  call :OpenModule "convert\mp4_h264.bat"
if "%CHOICE%"=="2"  call :OpenModule "convert\mp4_h265.bat"
if "%CHOICE%"=="3"  call :OpenModule "convert\webm_vp9.bat"
if "%CHOICE%"=="4"  call :OpenModule "convert\ogv.bat"
if "%CHOICE%"=="5"  call :OpenModule "convert\gif.bat"
if "%CHOICE%"=="6"  call :OpenModule "convert\mp3.bat"
if "%CHOICE%"=="7"  call :OpenModule "convert\wav.bat"
if "%CHOICE%"=="8"  call :OpenModule "convert\flac.bat"
if "%CHOICE%"=="9"  call :OpenModule "convert\opus.bat"
if "%CHOICE%"=="10" call :OpenModule "convert\aac.bat"
if "%CHOICE%"=="11" call :OpenModule "convert\ogg.bat"
if "%CHOICE%"=="12" call :OpenModule "convert\png.bat"
if "%CHOICE%"=="13" call :OpenModule "convert\jpeg.bat"
if "%CHOICE%"=="14" call :OpenModule "convert\webp.bat"
if "%CHOICE%"=="15" call :OpenModule "convert\avif.bat"
if "%CHOICE%"=="0"  goto EXIT_MODULE

if not "%CHOICE%"=="0" (
    echo.
    echo [ERROR] Некорректный выбор.
    echo.
    pause
)

goto MAIN_MENU


:OpenModule
call "%SELECTORS_DIR%\select_input_file.bat" || exit /b 1

set "MODULE_PATH=%MODULES_DIR%\%~1"

if not exist "%MODULE_PATH%" (
    echo.
    echo [ERROR] Не найден модуль:
    echo         %MODULE_PATH%
    echo.
    pause
    exit /b 1
)

call "%MODULE_PATH%"
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
