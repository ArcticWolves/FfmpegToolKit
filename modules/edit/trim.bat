@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\trim.bat
::
:: Обрезка видео и аудио.
::
:: Поддерживаются два режима:
::   1. Без перекодирования (stream copy)
::   2. С перекодированием
::
:: Используемые параметры FFmpeg:
::   -ss  : время начала
::   -to  : время окончания
::   -c copy
::
:: Документация:
::   https://ffmpeg.org/ffmpeg.html
:: ============================================================

:: ------------------------------------------------------------
:: Проверка конфигурации
:: ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FfmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

set "INPUT_FILE="
set "START_TIME="
set "END_TIME="
set "OUTPUT_NAME="
set "OUTPUT_FILE="
set "COPY_MODE="
set "EXTENSION="

:MAIN_MENU
cls

echo ============================================================
echo                           Trim
echo ============================================================
echo.
echo Обрезка видео или аудио по временному диапазону.
echo.
echo Пример:
echo   Начало : 00:01:30
echo   Конец  : 00:02:45
echo.
echo ============================================================
echo.

:: ------------------------------------------------------------
:: Ввод исходного файла
:: ------------------------------------------------------------
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto EXIT_MODULE

if not exist "%INPUT_FILE%" (
    echo.
    echo [ERROR] Файл не найден.
    echo.
    pause
    goto MAIN_MENU
)

:: ------------------------------------------------------------
:: Ввод времени начала
:: ------------------------------------------------------------
echo.
set /p "START_TIME=Введите время начала (HH:MM:SS): "

if "%START_TIME%"=="" (
    echo.
    echo [ERROR] Время начала не указано.
    pause
    goto MAIN_MENU
)

:: ------------------------------------------------------------
:: Ввод времени окончания
:: ------------------------------------------------------------
echo.
set /p "END_TIME=Введите время окончания (HH:MM:SS): "

if "%END_TIME%"=="" (
    echo.
    echo [ERROR] Время окончания не указано.
    pause
    goto MAIN_MENU
)

:: ------------------------------------------------------------
:: Режим обработки
:: ------------------------------------------------------------
:SELECT_MODE
echo.
echo ============================================================
echo Режим обработки:
echo.
echo  1. Без перекодирования (быстро, -c copy)
echo  2. С перекодированием
echo.
echo ============================================================
echo.

set "COPY_MODE="
set /p "COPY_MODE=Выберите режим: "

if "%COPY_MODE%"=="1" goto MODE_COPY
if "%COPY_MODE%"=="2" goto MODE_REENCODE

echo.
echo [ERROR] Некорректный выбор.
pause
goto SELECT_MODE


:MODE_COPY
set "USE_COPY=1"
goto BUILD_OUTPUT


:MODE_REENCODE
set "USE_COPY=0"
goto BUILD_OUTPUT


:: ------------------------------------------------------------
:: Формирование имени выходного файла
:: ------------------------------------------------------------
:BUILD_OUTPUT

for %%F in ("%INPUT_FILE%") do (
    set "BASE_NAME=%%~nF"
    set "EXTENSION=%%~xF"
)

set "OUTPUT_EXT=%EXTENSION:~1%"
set "OUTPUT_SUFFIX=trim"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto EXIT_MODULE

if "%USE_COPY%"=="0" (
    set "EDIT_ALLOW_AUDIO_COPY=1"
    call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
    if errorlevel 1 goto EXIT_MODULE
)


:: ------------------------------------------------------------
:: Подтверждение
:: ------------------------------------------------------------
cls
echo ============================================================
echo                    Подтверждение
echo ============================================================
echo.
echo Исходный файл:
echo   %INPUT_FILE%
echo.
echo Начало:
echo   %START_TIME%
echo.
echo Конец:
echo   %END_TIME%
echo.
echo Выходной файл:
echo   %OUTPUT_FILE%
echo.

if "%USE_COPY%"=="1" (
    echo Режим:
    echo   Без перекодирования (-c copy)
) else (
    echo Режим:
    echo   С перекодированием
)

echo.
echo ============================================================
echo.

choice /c YN /m "Начать обработку?"
if errorlevel 2 goto EXIT_MODULE


:: ------------------------------------------------------------
:: Выполнение FFmpeg
:: ------------------------------------------------------------
echo.
echo [INFO] Выполняется обработка...
echo.

if "%USE_COPY%"=="1" (
    "%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
        -ss %START_TIME% ^
        -to %END_TIME% ^
        -i "%INPUT_FILE%" ^
        -c copy ^
        "%OUTPUT_FILE%"
) else (
    "%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
        -ss %START_TIME% ^
        -to %END_TIME% ^
        -i "%INPUT_FILE%" ^
        -c:v %EDIT_VIDEO_CODEC% %EDIT_VIDEO_OPTIONS% ^
        -c:a %EDIT_AUDIO_CODEC% %EDIT_AUDIO_OPTIONS% ^
        "%OUTPUT_FILE%"
)

set "EXIT_CODE=%ERRORLEVEL%"

echo.
if "%EXIT_CODE%"=="0" (
    echo [SUCCESS] Обрезка завершена успешно.
    echo [SUCCESS] Файл сохранен:
    echo           %OUTPUT_FILE%
) else (
    echo [ERROR] FFmpeg завершился с кодом %EXIT_CODE%.
)

echo.
pause


:: ------------------------------------------------------------
:: Предложить воспроизведение результата
:: ------------------------------------------------------------
if "%EXIT_CODE%"=="0" if "%HAS_FFPLAY%"=="1" (
    choice /c YN /m "Открыть результат в FFplay?"
    if errorlevel 2 goto EXIT_MODULE

    "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
)

goto EXIT_MODULE


:EXIT_MODULE
endlocal
exit /b 0
