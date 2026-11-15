@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\tools.bat
rem Раздел "Инструменты". Контроллер утилит modules\tools\*.bat.
rem Утилиты сами выбирают нужные файлы (у некоторых входов несколько
rem или нет вовсе - например, запись экрана).
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Инструменты"
echo  --- Файлы ---------------------------------------------------
echo   1. Ремукс: сменить контейнер без перекодирования (mkv - mp4...)
echo   2. Удалить метаданные (GPS, камера, теги)
echo   3. Сравнить качество двух видео (VMAF / PSNR / SSIM)
echo.
echo  --- Картинки из медиа ----------------------------------------
echo   4. Контакт-лист: сетка превью кадров
echo   5. Волновая форма звука (PNG)
echo   6. Спектрограмма звука (PNG)
echo.
echo  --- Создание -------------------------------------------------
echo   7. Слайд-шоу из картинок папки input
echo   8. Видео из картинки и аудио (подкаст, музыка для YouTube)
echo   9. Запись экрана
echo  10. Тестовое видео (сетка + тон 1 кГц)
echo.
echo  --- Распознавание --------------------------------------------
echo  11. Субтитры из речи (Whisper, нужна модель)
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите инструмент"

set "T="
if "%CHOICE%"=="1"  set "T=remux"
if "%CHOICE%"=="2"  set "T=strip_metadata"
if "%CHOICE%"=="3"  set "T=quality_compare"
if "%CHOICE%"=="4"  set "T=contact_sheet"
if "%CHOICE%"=="5"  set "T=waveform"
if "%CHOICE%"=="6"  set "T=spectrum"
if "%CHOICE%"=="7"  set "T=slideshow"
if "%CHOICE%"=="8"  set "T=image_audio"
if "%CHOICE%"=="9"  set "T=screen_record"
if "%CHOICE%"=="10" set "T=test_video"
if "%CHOICE%"=="11" set "T=whisper"
if "%CHOICE%"=="0" goto EXIT_MODULE
if not defined T (call "%LIB%" :InvalidChoice & goto MAIN_MENU)

if not exist "%MODULES_DIR%\tools\%T%.bat" (
    echo [ERROR] Не найден модуль: %MODULES_DIR%\tools\%T%.bat
    pause
    goto MAIN_MENU
)
setlocal
call "%MODULES_DIR%\tools\%T%.bat"
endlocal
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
