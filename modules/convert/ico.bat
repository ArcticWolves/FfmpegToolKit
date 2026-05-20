@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\ico.bat
rem
rem Создание ICO (Windows Icon).
rem
rem Использование:
rem   - Из изображения или видеокадра создаётся .ico файл.
rem
rem Пользователь задаёт:
rem   - Таймкод
rem   - Размер иконки
rem
rem Особенности:
rem   - Формат предназначен для Windows.
rem   - Поддерживает прозрачность.
rem   - Обычно используются размеры:
rem       16x16, 32x32, 48x48, 64x64, 128x128, 256x256
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-formats.html
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
set "ICON_SIZE=256"

:MAIN_MENU
cls

echo ============================================================
echo                          ICO
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Размер иконки:
echo   %ICON_SIZE%x%ICON_SIZE%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать размер иконки
echo  3. Создать ICO
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SET_ICON_SIZE
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:SET_TIMECODE
cls
echo.
echo Примеры:
echo   00:00:00
echo   00:01:23.500
echo.
set "NEW_TIMECODE="
set /p "NEW_TIMECODE=Введите таймкод [%TIMECODE%]: "

if defined NEW_TIMECODE (
    set "TIMECODE=%NEW_TIMECODE%"
)

goto MAIN_MENU


:SET_ICON_SIZE
cls

echo ============================================================
echo                    Размер иконки
echo ============================================================
echo.
echo  1. 16x16
echo  2. 32x32
echo  3. 48x48
echo  4. 64x64
echo  5. 128x128
echo  6. 256x256 (рекомендуется)
echo  7. Пользовательское значение
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "SIZE_CHOICE="
set /p "SIZE_CHOICE=Выберите размер: "

if "%SIZE_CHOICE%"=="1" set "ICON_SIZE=16"  & goto MAIN_MENU
if "%SIZE_CHOICE%"=="2" set "ICON_SIZE=32"  & goto MAIN_MENU
if "%SIZE_CHOICE%"=="3" set "ICON_SIZE=48"  & goto MAIN_MENU
if "%SIZE_CHOICE%"=="4" set "ICON_SIZE=64"  & goto MAIN_MENU
if "%SIZE_CHOICE%"=="5" set "ICON_SIZE=128" & goto MAIN_MENU
if "%SIZE_CHOICE%"=="6" set "ICON_SIZE=256" & goto MAIN_MENU
if "%SIZE_CHOICE%"=="7" goto CUSTOM_ICON_SIZE
if "%SIZE_CHOICE%"=="0" goto MAIN_MENU

goto SET_ICON_SIZE


:CUSTOM_ICON_SIZE
cls
set "NEW_ICON_SIZE="
set /p "NEW_ICON_SIZE=Введите размер [%ICON_SIZE%]: "

if defined NEW_ICON_SIZE (
    set "ICON_SIZE=%NEW_ICON_SIZE%"
)

goto MAIN_MENU


:RUN
set "SAFE_TIMECODE=%TIMECODE::=-%"
set "SAFE_TIMECODE=%SAFE_TIMECODE:.=-%"
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%ICON_SIZE%x%ICON_SIZE%.ico"

cls
echo ============================================================
echo                    Создание ICO
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Размер:
echo   %ICON_SIZE%x%ICON_SIZE%
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
-vf "scale=%ICON_SIZE%:%ICON_SIZE%:flags=lanczos" ^
-c:v png ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось создать ICO.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo ICO файл:
echo   %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "OPEN_RESULT="
    set /p "OPEN_RESULT=Открыть изображение в FFplay? (Y/N): "

    if /i "%OPEN_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0