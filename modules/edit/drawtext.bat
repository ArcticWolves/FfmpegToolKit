@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\drawtext.bat
rem
rem Добавление текста на видео с использованием фильтра drawtext.
rem
rem Возможности:
rem   1. Произвольный текст.
rem   2. Выбор шрифта (.ttf / .otf).
rem   3. Размер шрифта.
rem   4. Цвет текста.
rem   5. Цвет рамки.
rem   6. Цвет тени.
rem   7. Прозрачность.
rem   8. Позиционирование.
rem   9. Ограничение по времени.
rem  10. Полупрозрачная подложка (box).
rem
rem Официальная документация:
rem https://ffmpeg.org/ffmpeg-filters.html#drawtext
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
    echo [ERROR] Сначала выберите входной файл.
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
    set "INPUT_EXT=%%~xF"
)

rem ------------------------------------------------------------
rem Значения по умолчанию
rem ------------------------------------------------------------
set "TEXT="
set "FONT_FILE="
set "FONT_SIZE=48"
set "FONT_COLOR=white"
set "BORDER_COLOR=black"
set "BORDER_WIDTH=2"
set "SHADOW_COLOR=black"
set "SHADOW_X=2"
set "SHADOW_Y=2"
set "BOX=0"
set "BOX_COLOR=black@0.5"
set "BOX_BORDER=10"
set "ALPHA=1.0"
set "ENABLE_TIME=0"
set "START_TIME=0"
set "END_TIME=0"
set "POS_X=(w-text_w)/2"
set "POS_Y=h-text_h-40"

goto ASK_TEXT


rem ============================================================
rem Ввод текста
rem ============================================================
:ASK_TEXT
cls
echo ============================================================
echo                     DrawText
echo ============================================================
echo.
echo Введите текст для наложения.
echo.
echo Пример:
echo   Demo Build
echo   Copyright 2026
echo   www.example.com
echo.

set "TEXT="
set /p "TEXT=Текст: "

if not defined TEXT (
    echo.
    echo [ERROR] Текст не может быть пустым.
    pause
    goto ASK_TEXT
)

goto ASK_FONT


rem ============================================================
rem Выбор шрифта
rem ============================================================
:ASK_FONT
cls
echo ============================================================
echo                     Выбор шрифта
echo ============================================================
echo.
echo Укажите путь к .ttf или .otf файлу.
echo.
echo Пример:
echo   C:\Windows\Fonts\arial.ttf
echo.
echo Оставьте пустым для использования Arial.
echo.

set "FONT_FILE="
set /p "FONT_FILE=Font file: "

if not defined FONT_FILE (
    set "FONT_FILE=C\:/Windows/Fonts/arial.ttf"
) else (
    if not exist "%FONT_FILE%" (
        echo.
        echo [ERROR] Файл шрифта не найден.
        pause
        goto ASK_FONT
    )
)

goto ASK_STYLE


rem ============================================================
rem Параметры текста
rem ============================================================
:ASK_STYLE
cls
echo ============================================================
echo                   Параметры текста
echo ============================================================
echo.

set /p "FONT_SIZE=Размер шрифта [48]: "
if not defined FONT_SIZE set "FONT_SIZE=48"

set /p "FONT_COLOR=Цвет текста [white]: "
if not defined FONT_COLOR set "FONT_COLOR=white"

set /p "ALPHA=Прозрачность (0.0-1.0) [1.0]: "
if not defined ALPHA set "ALPHA=1.0"

set /p "BORDER_WIDTH=Толщина рамки [2]: "
if not defined BORDER_WIDTH set "BORDER_WIDTH=2"

set /p "BORDER_COLOR=Цвет рамки [black]: "
if not defined BORDER_COLOR set "BORDER_COLOR=black"

goto ASK_BOX


rem ============================================================
rem Подложка
rem ============================================================
:ASK_BOX
cls
echo ============================================================
echo                    Подложка (Box)
echo ============================================================
echo.

set "BOX_CHOICE="
set /p "BOX_CHOICE=Добавить подложку? (Y/N): "

if /i "%BOX_CHOICE%"=="Y" (
    set "BOX=1"

    set /p "BOX_COLOR=Цвет подложки [black@0.5]: "
    if not defined BOX_COLOR set "BOX_COLOR=black@0.5"

    set /p "BOX_BORDER=Отступ внутри box [10]: "
    if not defined BOX_BORDER set "BOX_BORDER=10"
)

goto ASK_POSITION


rem ============================================================
rem Позиция
rem ============================================================
:ASK_POSITION
cls
echo ============================================================
echo                     Позиция текста
echo ============================================================
echo.
echo  1. Верхний левый угол
echo  2. Верхний правый угол
echo  3. Нижний левый угол
echo  4. Нижний правый угол
echo  5. По центру
echo  6. Пользовательская позиция
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите позицию: "

if "%CHOICE%"=="1" set "POS_X=20" & set "POS_Y=20" & goto ASK_TIME
if "%CHOICE%"=="2" set "POS_X=w-text_w-20" & set "POS_Y=20" & goto ASK_TIME
if "%CHOICE%"=="3" set "POS_X=20" & set "POS_Y=h-text_h-20" & goto ASK_TIME
if "%CHOICE%"=="4" set "POS_X=w-text_w-20" & set "POS_Y=h-text_h-20" & goto ASK_TIME
if "%CHOICE%"=="5" set "POS_X=(w-text_w)/2" & set "POS_Y=(h-text_h)/2" & goto ASK_TIME
if "%CHOICE%"=="6" goto CUSTOM_POSITION
if "%CHOICE%"=="0" goto EXIT_MODULE

goto ASK_POSITION


:CUSTOM_POSITION
cls
echo.
set /p "POS_X=X: "
set /p "POS_Y=Y: "

if not defined POS_X set "POS_X=20"
if not defined POS_Y set "POS_Y=20"

goto ASK_TIME


rem ============================================================
rem Ограничение по времени
rem ============================================================
:ASK_TIME
cls
echo ============================================================
echo                Ограничение по времени
echo ============================================================
echo.

set "TIME_CHOICE="
set /p "TIME_CHOICE=Показывать только в заданном интервале? (Y/N): "

if /i "%TIME_CHOICE%"=="Y" (
    set "ENABLE_TIME=1"

    set /p "START_TIME=Начало (сек) [0]: "
    if not defined START_TIME set "START_TIME=0"

    set /p "END_TIME=Конец (сек): "

    if not defined END_TIME (
        echo.
        echo [ERROR] Не указано время окончания.
        pause
        goto ASK_TIME
    )
)

goto BUILD_FILTER


rem ============================================================
rem Экранирование текста
rem ============================================================
:BUILD_FILTER
set "ESCAPED_TEXT=%TEXT%"
set "ESCAPED_TEXT=%ESCAPED_TEXT:\=\\%"
set "ESCAPED_TEXT=%ESCAPED_TEXT::=\:%"
set "ESCAPED_TEXT=%ESCAPED_TEXT:'=\'%"

set "DRAWTEXT_FILTER=drawtext="

set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%text='%ESCAPED_TEXT%'"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:fontfile='%FONT_FILE%'"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:fontsize=%FONT_SIZE%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:fontcolor=%FONT_COLOR%@%ALPHA%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:borderw=%BORDER_WIDTH%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:bordercolor=%BORDER_COLOR%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:shadowx=%SHADOW_X%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:shadowy=%SHADOW_Y%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:shadowcolor=%SHADOW_COLOR%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:x=%POS_X%"
set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:y=%POS_Y%"

if "%BOX%"=="1" (
    set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:box=1"
    set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:boxcolor=%BOX_COLOR%"
    set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:boxborderw=%BOX_BORDER%"
)

if "%ENABLE_TIME%"=="1" (
    set "DRAWTEXT_FILTER=%DRAWTEXT_FILTER%:enable='between(t,%START_TIME%,%END_TIME%)'"
)

goto RUN


rem ============================================================
rem Выполнение
rem ============================================================
:RUN
cls

set "OUTPUT_FILE=%OUTPUT_DIR%\%INPUT_NAME%_text%INPUT_EXT%"

echo ============================================================
echo                    Добавление текста
echo ============================================================
echo.
echo Текст:
echo %TEXT%
echo.
echo Фильтр:
echo %DRAWTEXT_FILTER%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%DRAWTEXT_FILTER%" ^
-c:v libopenh264 ^
-b:v 5M ^
-c:a copy ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Обработка завершилась с ошибкой.
    echo.
    pause
    goto ASK_TEXT
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
goto ASK_TEXT


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0
