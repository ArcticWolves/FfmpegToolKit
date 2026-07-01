@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\psd.bat
rem
rem Извлечение кадра из видео или конвертация изображения в PSD.
rem
rem Формат:
rem   Adobe Photoshop Document (.psd)
rem
rem Особенности:
rem   - Поддерживает RGB и RGBA.
rem   - Поддерживает 8-bit и 16-bit.
rem   - Слои FFmpeg не создаёт; сохраняется один flattened image.
rem   - Удобен для дальнейшего редактирования в Photoshop/Krita.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Pixel Format
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html#psd
rem ============================================================

rem ------------------------------------------------------------
rem Проверка конфигурации
rem ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

if not "%HAS_PSD_ENCODER%"=="1" (
    echo.
    echo [ERROR] PSD недоступен в текущей сборке FFmpeg.
    echo [ERROR] Не найден encoder: psd
    echo.
    pause
    exit /b 1
)

rem ------------------------------------------------------------
rem Проверка входного файла
rem ------------------------------------------------------------
if not defined INPUT_FILE (
    echo.
    echo [ERROR] INPUT_FILE не задан.
    echo.
    pause
    exit /b 1
)

if not exist "%INPUT_FILE%" (
    echo.
    echo [ERROR] Входной файл не найден:
    echo         %INPUT_FILE%
    echo.
    pause
    exit /b 1
)

rem ------------------------------------------------------------
rem Получение имени файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Параметры по умолчанию
rem ------------------------------------------------------------
set "TIMECODE=00:00:00"
set "PIX_FMT=rgba"

:MAIN_MENU
cls

echo ============================================================
echo                           PSD
echo ============================================================
echo.
echo Входной файл:
echo   %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать Pixel Format
echo  3. Создать PSD
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_PIXEL_FORMAT
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Ввод таймкода
rem ============================================================
:SET_TIMECODE
cls

echo ============================================================
echo                       Таймкод
echo ============================================================
echo.
echo Примеры:
echo   00:00:00
echo   00:01:23
echo   00:01:23.500
echo.
echo Текущее значение:
echo   %TIMECODE%
echo.

set "NEW_TIMECODE="
set /p "NEW_TIMECODE=Введите таймкод [%TIMECODE%]: "

if defined NEW_TIMECODE (
    set "TIMECODE=%NEW_TIMECODE%"
)

goto MAIN_MENU


rem ============================================================
rem Выбор Pixel Format
rem ============================================================
:SET_PIXEL_FORMAT
cls

echo ============================================================
echo                      Pixel Format
echo ============================================================
echo.
echo  1. rgb24       (8-bit RGB)
echo  2. rgba        (8-bit RGBA) [Recommended]
echo  3. rgb48le     (16-bit RGB)
echo  4. rgba64le    (16-bit RGBA)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "FMT_CHOICE="
set /p "FMT_CHOICE=Выберите формат: "

if "%FMT_CHOICE%"=="1" set "PIX_FMT=rgb24"
if "%FMT_CHOICE%"=="1" goto MAIN_MENU
if "%FMT_CHOICE%"=="2" set "PIX_FMT=rgba"
if "%FMT_CHOICE%"=="2" goto MAIN_MENU
if "%FMT_CHOICE%"=="3" set "PIX_FMT=rgb48le"
if "%FMT_CHOICE%"=="3" goto MAIN_MENU
if "%FMT_CHOICE%"=="4" set "PIX_FMT=rgba64le"
if "%FMT_CHOICE%"=="4" goto MAIN_MENU
if "%FMT_CHOICE%"=="0" goto MAIN_MENU

goto SET_PIXEL_FORMAT


rem ============================================================
rem Создание PSD
rem ============================================================
:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_EXT=psd"
set "OUTPUT_SUFFIX=%SAFE_TIMECODE%"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Создание PSD
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Pixel Format:
echo   %PIX_FMT%
echo.
echo Выходной файл:
echo   %OUTPUT_FILE%
echo.
echo ============================================================
echo.
echo Нажмите любую клавишу для запуска...
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-ss %TIMECODE% ^
-i "%INPUT_FILE%" ^
-frames:v 1 ^
-c:v psd ^
-pix_fmt %PIX_FMT% ^
-f image2 ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать PSD.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo PSD файл:
echo   %OUTPUT_FILE%
echo.
echo Примечание:
echo   PSD содержит одно объединённое изображение без слоёв.
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "OPEN_RESULT="
    set /p "OPEN_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%OPEN_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
