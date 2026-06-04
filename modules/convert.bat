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
echo  6. APNG
echo.
echo ---------------- Аудио ----------------
echo  7. MP3
echo  8. WAV
echo  9. FLAC
echo 10. Opus
echo 11. AAC (M4A)
echo 12. OGG Vorbis
echo.
echo ---------------- Изображения ----------
echo 13. PNG
echo 14. JPEG
echo 15. WebP
echo 16. AVIF
echo 17. TIFF
echo 18. BMP
echo 19. ICO
echo.
echo ---------------- Advanced Images ------
echo 20. DPX
echo 21. DDS
echo 22. HDR
echo 23. JP2
echo 24. JXL
echo 25. PAM
echo 26. PBM
echo 27. PGM
echo 28. PPM
echo 29. PSD
echo 30. CIN
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите формат: "

set "HANDLED=0"

if "%CHOICE%"=="1"  set "HANDLED=1" & call :OpenModule "convert\mp4_h264.bat"
if "%CHOICE%"=="2"  set "HANDLED=1" & call :OpenModule "convert\mp4_h265.bat"
if "%CHOICE%"=="3"  set "HANDLED=1" & call :OpenModule "convert\webm_vp9.bat"
if "%CHOICE%"=="4"  set "HANDLED=1" & call :OpenModule "convert\ogv.bat"
if "%CHOICE%"=="5"  set "HANDLED=1" & call :OpenModule "convert\gif.bat"
if "%CHOICE%"=="6"  set "HANDLED=1" & call :OpenModule "convert\apng.bat"
if "%CHOICE%"=="7"  set "HANDLED=1" & call :OpenModule "convert\mp3.bat"
if "%CHOICE%"=="8"  set "HANDLED=1" & call :OpenModule "convert\wav.bat"
if "%CHOICE%"=="9"  set "HANDLED=1" & call :OpenModule "convert\flac.bat"
if "%CHOICE%"=="10" set "HANDLED=1" & call :OpenModule "convert\opus.bat"
if "%CHOICE%"=="11" set "HANDLED=1" & call :OpenModule "convert\aac.bat"
if "%CHOICE%"=="12" set "HANDLED=1" & call :OpenModule "convert\ogg.bat"
if "%CHOICE%"=="13" set "HANDLED=1" & call :OpenModule "convert\png.bat"
if "%CHOICE%"=="14" set "HANDLED=1" & call :OpenModule "convert\jpeg.bat"
if "%CHOICE%"=="15" set "HANDLED=1" & call :OpenModule "convert\webp.bat"
if "%CHOICE%"=="16" set "HANDLED=1" & call :OpenModule "convert\avif.bat"
if "%CHOICE%"=="17" set "HANDLED=1" & call :OpenModule "convert\tiff.bat"
if "%CHOICE%"=="18" set "HANDLED=1" & call :OpenModule "convert\bmp.bat"
if "%CHOICE%"=="19" set "HANDLED=1" & call :OpenModule "convert\ico.bat"
if "%CHOICE%"=="20" set "HANDLED=1" & call :OpenModule "convert\dpx.bat"
if "%CHOICE%"=="21" set "HANDLED=1" & call :OpenModule "convert\dds.bat"
if "%CHOICE%"=="22" set "HANDLED=1" & call :OpenModule "convert\hdr.bat"
if "%CHOICE%"=="23" set "HANDLED=1" & call :OpenModule "convert\jp2.bat"
if "%CHOICE%"=="24" set "HANDLED=1" & call :OpenModule "convert\jxl.bat"
if "%CHOICE%"=="25" set "HANDLED=1" & call :OpenModule "convert\pam.bat"
if "%CHOICE%"=="26" set "HANDLED=1" & call :OpenModule "convert\pbm.bat"
if "%CHOICE%"=="27" set "HANDLED=1" & call :OpenModule "convert\pgm.bat"
if "%CHOICE%"=="28" set "HANDLED=1" & call :OpenModule "convert\ppm.bat"
if "%CHOICE%"=="29" set "HANDLED=1" & call :OpenModule "convert\psd.bat"
if "%CHOICE%"=="30" set "HANDLED=1" & call :OpenModule "convert\cin.bat"
if "%CHOICE%"=="0"  goto EXIT_MODULE

if "%HANDLED%"=="0" (
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
