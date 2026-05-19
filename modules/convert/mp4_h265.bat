@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\mp4_h265.bat
rem
rem Конвертация в MP4 (H.265/HEVC + AAC)
rem
rem Использует пользовательские селекторы:
rem   selectors\select_video_codec.bat
rem   selectors\select_audio_codec.bat
rem
rem По умолчанию:
rem   Video : libx265
rem   Audio : aac
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
rem Получение имени входного файла
rem ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
)

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "VIDEO_CODEC=libx265"
set "VIDEO_CODEC_OPTIONS=-preset medium -crf 22 -tag:v hvc1 -pix_fmt yuv420p"

set "AUDIO_CODEC=aac"
set "AUDIO_CODEC_OPTIONS=-b:a 192k"

:MAIN_MENU
cls

echo ============================================================
echo                 MP4 (H.265 + AAC)
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Видеокодек:
echo   %VIDEO_CODEC%
echo   %VIDEO_CODEC_OPTIONS%
echo.
echo Аудиокодек:
echo   %AUDIO_CODEC%
echo   %AUDIO_CODEC_OPTIONS%
echo.
echo ============================================================
echo.
echo  1. Выбрать видеокодек
echo  2. Выбрать аудиокодек
echo  3. Запустить конвертацию
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SELECT_VIDEO_CODEC
if "%CHOICE%"=="2" goto SELECT_AUDIO_CODEC
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


:SELECT_VIDEO_CODEC
if exist "%ROOT%\selectors\select_video_codec.bat" (
    call "%ROOT%\selectors\select_video_codec.bat"
) else (
    echo.
    echo [ERROR] Не найден селектор:
    echo         %ROOT%\selectors\select_video_codec.bat
    echo.
    pause
)

if not defined VIDEO_CODEC (
    set "VIDEO_CODEC=libx265"
)

if not defined VIDEO_CODEC_OPTIONS (
    set "VIDEO_CODEC_OPTIONS=-preset medium -crf 22 -tag:v hvc1 -pix_fmt yuv420p"
)

goto MAIN_MENU


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
    set "AUDIO_CODEC=aac"
)

if not defined AUDIO_CODEC_OPTIONS (
    set "AUDIO_CODEC_OPTIONS=-b:a 192k"
)

goto MAIN_MENU


:RUN
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_h265.mp4"

cls
echo ============================================================
echo                    Конвертация
echo ============================================================
echo.
echo Video codec:
echo   %VIDEO_CODEC%
echo   %VIDEO_CODEC_OPTIONS%
echo.
echo Audio codec:
echo   %AUDIO_CODEC%
echo   %AUDIO_CODEC_OPTIONS%
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
-c:v %VIDEO_CODEC% %VIDEO_CODEC_OPTIONS% ^
-c:a %AUDIO_CODEC% %AUDIO_CODEC_OPTIONS% ^
-movflags +faststart ^
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


:EXIT_MODULE
endlocal
exit /b 0