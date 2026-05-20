@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\convert\png.bat
rem
rem Извлечение кадра из видео или конвертация изображения в PNG.
rem
rem Если входной файл является видео, пользователь указывает
rem таймкод (например 00:01:23.500), из которого будет извлечён
rem кадр.
rem
rem Если оставить поле пустым, используется таймкод 00:00:00.
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg.html
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
rem Значения по умолчанию
rem ------------------------------------------------------------
set "VIDEO_CODEC=png"
set "VIDEO_CODEC_OPTIONS="
set "TIMECODE=00:00:00"

:MAIN_MENU
cls

echo ============================================================
echo                    Извлечение PNG
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Таймкод:
echo   %TIMECODE%
echo.
echo Видеокодек:
echo   %VIDEO_CODEC%
if defined VIDEO_CODEC_OPTIONS echo   %VIDEO_CODEC_OPTIONS%
echo.
echo ============================================================
echo.
echo  1. Указать таймкод
echo  2. Выбрать видеокодек
echo  3. Извлечь кадр
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto SET_TIMECODE
if "%CHOICE%"=="2" goto SELECT_VIDEO_CODEC
if "%CHOICE%"=="3" goto RUN
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
pause
goto MAIN_MENU


rem ============================================================
rem Ввод таймкода
rem ============================================================
:SET_TIMECODE
cls

echo ============================================================
echo                     Таймкод
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
set /p "NEW_TIMECODE=Введите таймкод [00:00:00]: "

if defined NEW_TIMECODE (
    set "TIMECODE=%NEW_TIMECODE%"
)

goto MAIN_MENU


rem ============================================================
rem Выбор видеокодека
rem ============================================================
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
    set "VIDEO_CODEC=png"
)

goto MAIN_MENU


rem ============================================================
rem Извлечение кадра
rem ============================================================
:RUN
set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_%TIMECODE::=-%.png"
set "OUTPUT_FILE=%OUTPUT_FILE:.=-%"

cls
echo ============================================================
echo                  Извлечение кадра
echo ============================================================
echo.
echo Таймкод:
echo   %TIMECODE%
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
-c:v %VIDEO_CODEC% %VIDEO_CODEC_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Не удалось извлечь кадр.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo PNG файл:
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


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0