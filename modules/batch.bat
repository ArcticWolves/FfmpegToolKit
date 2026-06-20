@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\batch.bat
rem
rem Batch conversion for all files in INPUT_DIR using presets.
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
echo                  Пакетная конвертация
echo ============================================================
echo.
echo Входная папка:
echo %INPUT_DIR%
echo.
echo Выходная папка:
echo %OUTPUT_DIR%
echo.
echo  1. Выбрать preset и конвертировать все файлы
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SELECT_PRESET
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU

:SELECT_PRESET
call "%MODULES_DIR%\presets.bat"
if errorlevel 1 goto MAIN_MENU

set "INPUT_COUNT=0"
for %%F in ("%INPUT_DIR%\*.*") do (
    if exist "%%~fF" (
        set /a INPUT_COUNT+=1
    )
)

if "%INPUT_COUNT%"=="0" (
    echo.
    echo [INFO] Во входной папке нет файлов.
    echo.
    pause
    goto MAIN_MENU
)

cls
echo ============================================================
echo                  Пакетная конвертация
echo ============================================================
echo.
echo Preset:
echo %PRESET_NAME%
echo.
echo Файлов найдено:
echo %INPUT_COUNT%
echo.
echo Аргументы:
echo %PRESET_ARGS%
echo.
echo ============================================================
echo.
choice /c YN /m "Начать пакетную конвертацию?"
if errorlevel 2 goto MAIN_MENU

set "DONE_COUNT=0"
set "FAIL_COUNT=0"

for %%F in ("%INPUT_DIR%\*.*") do (
    if exist "%%~fF" (
        set "SOURCE_FILE=%%~fF"
        set "OUTPUT_FILE=%OUTPUT_DIR%\%%~nF.%PRESET_EXT%"

        echo.
        echo ------------------------------------------------------------
        echo Вход:
        echo !SOURCE_FILE!
        echo Выход:
        echo !OUTPUT_FILE!

        "%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% -i "!SOURCE_FILE!" %PRESET_ARGS% "!OUTPUT_FILE!"

        if errorlevel 1 (
            set /a FAIL_COUNT+=1
            echo [ERROR] Не удалось конвертировать: %%~nxF
        ) else (
            set /a DONE_COUNT+=1
            echo [OK] %%~nxF
        )
    )
)

echo.
echo ============================================================
echo                       Завершено
echo ============================================================
echo.
echo Успешно: !DONE_COUNT!
echo Ошибок : !FAIL_COUNT!
echo.
pause
goto MAIN_MENU

:EXIT_MODULE
endlocal
exit /b 0
