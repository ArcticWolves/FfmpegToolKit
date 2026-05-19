@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\ffplay.bat
rem
rem Модуль воспроизведения мультимедиа через FFplay.
rem ============================================================

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

if "%HAS_FFPLAY%"=="0" (
    echo.
    echo [ERROR] ffplay.exe не найден.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls
echo ============================================================
echo                         FFplay
echo ============================================================
echo.
echo  1. Воспроизвести последний файл
echo  2. Воспроизвести без звука
echo  3. Воспроизвести без видео
echo  4. Полноэкранный режим
echo  5. Зацикленное воспроизведение
echo  6. Воспроизвести указанный файл
echo  7. Тестовое видео
echo  8. Тестовый звук
echo  9. Пользовательские параметры
echo.
echo  0. Назад
echo.
echo ============================================================
echo.
echo Space      - Пауза / Продолжить
echo Left/Right - Перемотка на 10 секунд
echo Up/Down    - Перемотка на 1 минуту
echo M          - Вкл./выкл. звук
echo 9 / 0      - Громкость
echo F          - Полный экран
echo S          - Скриншот
echo Q / Esc    - Выход
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" call :PlayLast ""
if "%CHOICE%"=="2" call :PlayLast "-an"
if "%CHOICE%"=="3" call :PlayLast "-vn"
if "%CHOICE%"=="4" call :PlayLast "-fs"
if "%CHOICE%"=="5" call :PlayLast "-loop 0"
if "%CHOICE%"=="6" goto PLAY_CUSTOM_FILE
if "%CHOICE%"=="7" goto TEST_VIDEO
if "%CHOICE%"=="8" goto TEST_AUDIO
if "%CHOICE%"=="9" goto CUSTOM_OPTIONS
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:PlayLast
call :GetLastOutputFile
if not defined INPUT_FILE goto MAIN_MENU
call :RunFFplay "%INPUT_FILE%" %~1
goto MAIN_MENU


:PLAY_CUSTOM_FILE
call :AskFile
if not defined INPUT_FILE goto MAIN_MENU
call :RunFFplay "%INPUT_FILE%"
goto MAIN_MENU


:CUSTOM_OPTIONS
call :AskFile
if not defined INPUT_FILE goto MAIN_MENU

echo.
set "USER_OPTIONS="
set /p "USER_OPTIONS=Введите дополнительные параметры FFplay: "

call :RunFFplay "%INPUT_FILE%" %USER_OPTIONS%
goto MAIN_MENU


:TEST_VIDEO
"%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% ^
-f lavfi ^
-i "testsrc=size=1280x720:rate=30"
goto MAIN_MENU


:TEST_AUDIO
"%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% ^
-f lavfi ^
-i "sine=frequency=440:sample_rate=48000"
goto MAIN_MENU


:RunFFplay
set "PLAY_FILE=%~1"
shift
set "PLAY_OPTIONS=%*"

cls
echo ============================================================
echo Воспроизведение:
echo %PLAY_FILE%
echo.
echo Параметры:
echo %PLAY_OPTIONS%
echo ============================================================
echo.

"%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% %PLAY_OPTIONS% "%PLAY_FILE%"

echo.
pause
exit /b 0


:AskFile
set "INPUT_FILE="
echo.
set /p "INPUT_FILE=Введите путь к файлу: "

if not defined INPUT_FILE exit /b 0

if not exist "%INPUT_FILE%" (
    echo.
    echo [ERROR] Файл не найден:
    echo %INPUT_FILE%
    echo.
    pause
    set "INPUT_FILE="
)

exit /b 0


:GetLastOutputFile
set "INPUT_FILE="

for /f "delims=" %%F in ('
    dir /b /a-d /o-d "%OUTPUT_DIR%" 2^>nul
') do (
    set "INPUT_FILE=%OUTPUT_DIR%\%%F"
    goto :EOF
)

echo.
echo [ERROR] В папке output нет файлов.
echo.
pause
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0