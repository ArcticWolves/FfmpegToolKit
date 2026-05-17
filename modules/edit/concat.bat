@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit\concat.bat
rem
rem Склейка нескольких файлов с использованием concat demuxer.
rem
rem Назначение:
rem   Объединяет несколько видео- или аудиофайлов в один файл
rem   без перекодирования (stream copy).
rem
rem Требования:
rem   - Все входные файлы должны иметь одинаковые параметры:
rem       * одинаковый контейнер;
rem       * одинаковые кодеки;
rem       * одинаковые параметры потоков.
rem
rem Используемый механизм:
rem   ffmpeg -f concat -safe 0 -i list.txt -c copy output.ext
rem
rem Официальная документация:
rem   https://ffmpeg.org/ffmpeg-formats.html#concat
rem ============================================================

rem ------------------------------------------------------------
rem Проверка конфигурации
rem ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FfmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

rem ------------------------------------------------------------
rem Подготовка рабочего каталога
rem ------------------------------------------------------------
set "CONCAT_DIR=%TEMP_DIR%\concat"

if not exist "%CONCAT_DIR%" (
    mkdir "%CONCAT_DIR%"
)

set "LIST_FILE=%CONCAT_DIR%\concat_list.txt"

:MAIN_MENU
cls

echo ============================================================
echo                         Склейка
echo ============================================================
echo.
echo Метод:
echo   Concat Demuxer (без перекодирования)
echo.
echo Требования:
echo   Все файлы должны иметь одинаковые параметры.
echo.
echo ============================================================
echo.
echo  1. Автоматически использовать все файлы из input
echo  2. Создать список вручную
echo  3. Открыть временную папку concat
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto AUTO_BUILD_LIST
if "%CHOICE%"=="2" goto MANUAL_BUILD_LIST
if "%CHOICE%"=="3" goto OPEN_TEMP_FOLDER
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem Автоматическое создание списка
rem ============================================================
:AUTO_BUILD_LIST
cls

echo ============================================================
echo           Автоматическое создание списка файлов
echo ============================================================
echo.

del /q "%LIST_FILE%" >nul 2>&1

set "FILE_COUNT=0"
set "FIRST_EXT="

for %%F in ("%INPUT_DIR%\*.*") do (
    if exist "%%~fF" (
        if not defined FIRST_EXT (
            set "FIRST_EXT=%%~xF"
        )

        if /i "%%~xF"=="!FIRST_EXT!" (
            >> "%LIST_FILE%" echo file '%%~fF'
            set /a FILE_COUNT+=1
        )
    )
)

if "!FILE_COUNT!"=="0" (
    echo [ERROR] В папке input нет файлов.
    echo.
    pause
    goto MAIN_MENU
)

if "!FILE_COUNT!"=="1" (
    echo [ERROR] Для склейки требуется минимум два файла.
    echo.
    pause
    goto MAIN_MENU
)

echo Найдено файлов: !FILE_COUNT!
echo Расширение: !FIRST_EXT!
echo.
echo Список создан:
echo %LIST_FILE%
echo.
pause

goto PREPARE_OUTPUT


rem ============================================================
rem Ручное создание списка
rem ============================================================
:MANUAL_BUILD_LIST
cls

echo ============================================================
echo             Ручное создание списка файлов
echo ============================================================
echo.
echo Введите полные пути к файлам.
echo Для завершения введите пустую строку.
echo.

del /q "%LIST_FILE%" >nul 2>&1

set "FILE_COUNT=0"

:INPUT_LOOP
set "CURRENT_FILE="
set /p "CURRENT_FILE=Файл !FILE_COUNT!: "

if not defined CURRENT_FILE goto CHECK_MANUAL_COUNT

if not exist "%CURRENT_FILE%" (
    echo.
    echo [ERROR] Файл не найден.
    echo.
    goto INPUT_LOOP
)

>> "%LIST_FILE%" echo file '%CURRENT_FILE%'
set /a FILE_COUNT+=1

goto INPUT_LOOP


:CHECK_MANUAL_COUNT
if "!FILE_COUNT!"=="0" (
    echo.
    echo [ERROR] Не добавлено ни одного файла.
    echo.
    pause
    goto MAIN_MENU
)

if "!FILE_COUNT!"=="1" (
    echo.
    echo [ERROR] Для склейки требуется минимум два файла.
    echo.
    pause
    goto MAIN_MENU
)

echo.
echo Добавлено файлов: !FILE_COUNT!
echo.
pause

goto PREPARE_OUTPUT


rem ============================================================
rem Подготовка выходного файла
rem ============================================================
:PREPARE_OUTPUT
cls

for /f "usebackq delims=" %%L in ("%LIST_FILE%") do (
    set "FIRST_LINE=%%L"
    goto GOT_FIRST_LINE
)

:GOT_FIRST_LINE

rem Извлекаем путь первого файла
set "FIRST_FILE=!FIRST_LINE:file '=!"
set "FIRST_FILE=!FIRST_FILE:'=!"

for %%F in ("!FIRST_FILE!") do (
    set "INPUT_EXT=%%~xF"
    set "BASE_NAME=%%~nF"
)

set "DEFAULT_OUTPUT=%OUTPUT_DIR%\%BASE_NAME%_concat%INPUT_EXT%"

echo ============================================================
echo                 Настройка выходного файла
echo ============================================================
echo.
echo Предлагаемый файл:
echo %DEFAULT_OUTPUT%
echo.
echo Нажмите Enter, чтобы использовать путь по умолчанию.
echo.

set "OUTPUT_FILE="
set /p "OUTPUT_FILE=Выходной файл: "

if not defined OUTPUT_FILE (
    set "OUTPUT_FILE=%DEFAULT_OUTPUT%"
)

goto RUN_CONCAT


rem ============================================================
rem Выполнение склейки
rem ============================================================
:RUN_CONCAT
cls

echo ============================================================
echo                    Выполнение склейки
echo ============================================================
echo.
echo Список файлов:
echo %LIST_FILE%
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Команда:
echo "%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% -f concat -safe 0 -i "%LIST_FILE%" -c copy "%OUTPUT_FILE%"
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-f concat ^
-safe 0 ^
-i "%LIST_FILE%" ^
-c copy ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Склейка завершилась с ошибкой.
    echo.
    echo Возможные причины:
    echo - файлы имеют разные кодеки;
    echo - разные параметры видео или аудио;
    echo - поврежденные входные файлы.
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
    set "PLAY_RESULT="
    set /p "PLAY_RESULT=Открыть результат в FFplay? (Y/N): "

    if /i "%PLAY_RESULT%"=="Y" (
        "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% "%OUTPUT_FILE%"
    )
)

pause
goto MAIN_MENU


rem ============================================================
rem Открытие временной папки
rem ============================================================
:OPEN_TEMP_FOLDER
start "" "%CONCAT_DIR%"
goto MAIN_MENU


rem ============================================================
rem Выход
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0