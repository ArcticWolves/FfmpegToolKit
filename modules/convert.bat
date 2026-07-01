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
if "%HAS_DDS_ENCODER%"=="1" (
    echo 21. DDS
) else (
    echo 21. DDS [encoder недоступен]
)
echo 22. HDR
echo 23. JP2
echo 24. JXL
echo 25. PAM
echo 26. PBM
echo 27. PGM
echo 28. PPM
if "%HAS_PSD_ENCODER%"=="1" (
    echo 29. PSD
) else (
    echo 29. PSD [encoder недоступен]
)
if "%HAS_CINEON_ENCODER%"=="1" (
    echo 30. CIN
) else (
    echo 30. CIN [encoder недоступен]
)
echo 31. EXR
echo 32. PNM
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите формат: "

if "%CHOICE%"=="0" goto EXIT_MODULE

if "%CHOICE%"=="21" if not "%HAS_DDS_ENCODER%"=="1" goto DDS_UNAVAILABLE
if "%CHOICE%"=="29" if not "%HAS_PSD_ENCODER%"=="1" goto PSD_UNAVAILABLE
if "%CHOICE%"=="30" if not "%HAS_CINEON_ENCODER%"=="1" goto CINEON_UNAVAILABLE

set "MODULE_REL="
if "%CHOICE%"=="1"  set "MODULE_REL=convert\mp4_h264.bat"
if "%CHOICE%"=="2"  set "MODULE_REL=convert\mp4_h265.bat"
if "%CHOICE%"=="3"  set "MODULE_REL=convert\webm_vp9.bat"
if "%CHOICE%"=="4"  set "MODULE_REL=convert\ogv.bat"
if "%CHOICE%"=="5"  set "MODULE_REL=convert\gif.bat"
if "%CHOICE%"=="6"  set "MODULE_REL=convert\apng.bat"
if "%CHOICE%"=="7"  set "MODULE_REL=convert\mp3.bat"
if "%CHOICE%"=="8"  set "MODULE_REL=convert\wav.bat"
if "%CHOICE%"=="9"  set "MODULE_REL=convert\flac.bat"
if "%CHOICE%"=="10" set "MODULE_REL=convert\opus.bat"
if "%CHOICE%"=="11" set "MODULE_REL=convert\aac.bat"
if "%CHOICE%"=="12" set "MODULE_REL=convert\ogg.bat"
if "%CHOICE%"=="13" set "MODULE_REL=convert\png.bat"
if "%CHOICE%"=="14" set "MODULE_REL=convert\jpeg.bat"
if "%CHOICE%"=="15" set "MODULE_REL=convert\webp.bat"
if "%CHOICE%"=="16" set "MODULE_REL=convert\avif.bat"
if "%CHOICE%"=="17" set "MODULE_REL=convert\tiff.bat"
if "%CHOICE%"=="18" set "MODULE_REL=convert\bmp.bat"
if "%CHOICE%"=="19" set "MODULE_REL=convert\ico.bat"
if "%CHOICE%"=="20" set "MODULE_REL=convert\dpx.bat"
if "%CHOICE%"=="21" set "MODULE_REL=convert\dds.bat"
if "%CHOICE%"=="22" set "MODULE_REL=convert\hdr.bat"
if "%CHOICE%"=="23" set "MODULE_REL=convert\jp2.bat"
if "%CHOICE%"=="24" set "MODULE_REL=convert\jxl.bat"
if "%CHOICE%"=="25" set "MODULE_REL=convert\pam.bat"
if "%CHOICE%"=="26" set "MODULE_REL=convert\pbm.bat"
if "%CHOICE%"=="27" set "MODULE_REL=convert\pgm.bat"
if "%CHOICE%"=="28" set "MODULE_REL=convert\ppm.bat"
if "%CHOICE%"=="29" set "MODULE_REL=convert\psd.bat"
if "%CHOICE%"=="30" set "MODULE_REL=convert\cin.bat"
if "%CHOICE%"=="31" set "MODULE_REL=convert\exr.bat"
if "%CHOICE%"=="32" set "MODULE_REL=convert\pnm.bat"

if defined MODULE_REL (
    call :OpenModule "%MODULE_REL%"
    goto MAIN_MENU
)

echo.
echo [ERROR] Некорректный выбор.
echo.
pause

goto MAIN_MENU


:DDS_UNAVAILABLE
call :EncoderUnavailable "DDS" "dds"
goto MAIN_MENU


:PSD_UNAVAILABLE
call :EncoderUnavailable "PSD" "psd"
goto MAIN_MENU


:CINEON_UNAVAILABLE
call :EncoderUnavailable "CIN/Cineon" "cineon"
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


:EncoderUnavailable
echo.
echo [ERROR] %~1 недоступен в текущей сборке FFmpeg.
echo [ERROR] Не найден encoder: %~2
echo [ERROR] Замените FFmpeg на сборку с этим encoder или выберите другой формат.
echo.
pause
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
