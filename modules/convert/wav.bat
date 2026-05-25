@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\wav.bat
rem
rem Конвертация в WAV.
rem
rem Использует пользовательский селектор аудиокодека:
rem   selectors\select_audio_codec.bat
rem
rem По умолчанию:
rem   Audio codec : pcm_s16le
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-codecs.html
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

set "TARGET_CONTAINER=wav"
set "OUTPUT_EXT=wav"
set "OUTPUT_SUFFIX=wav"

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "AUDIO_CODEC=pcm_s16le"
set "AUDIO_CODEC_OPTIONS="

:MAIN_MENU
cls

echo ============================================================
echo                          WAV
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Аудиокодек:
echo   %AUDIO_CODEC%
if defined AUDIO_CODEC_OPTIONS echo   %AUDIO_CODEC_OPTIONS%
echo.
echo ============================================================
echo.
echo  1. Выбрать аудиокодек
echo  2. Запустить конвертацию
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SELECT_AUDIO_CODEC
if "%CHOICE%"=="2" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


rem ============================================================
rem Выбор аудиокодека
rem ============================================================
:SELECT_AUDIO_CODEC
if exist "%ROOT%\selectors\select_audio_codec.bat" (
    call "%ROOT%\selectors\select_audio_codec.bat"
) else (
    echo.
    echo [ERROR] Не найден селектор:
    echo         %ROOT%\selectors\select_audio_codec.bat
    echo.
    pause
)

if not defined AUDIO_CODEC (
    set "AUDIO_CODEC=pcm_s16le"
)

goto MAIN_MENU


rem ============================================================
rem Выполнение конвертации
rem ============================================================
:RUN
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

cls
echo ============================================================
echo                    Конвертация в WAV
echo ============================================================
echo.
echo Audio codec:
echo   %AUDIO_CODEC%
if defined AUDIO_CODEC_OPTIONS echo   %AUDIO_CODEC_OPTIONS%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo ============================================================
echo.
echo Нажмите любую клавишу для запуска...
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vn ^
-c:a %AUDIO_CODEC% %AUDIO_CODEC_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Конвертация завершилась с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.

if "%HAS_FFPLAY%"=="1" (
    echo.
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%PLAY_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0
