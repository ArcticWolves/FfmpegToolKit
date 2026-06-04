@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: modules\edit\stabilizators\vidstabtransform.bat
::
:: Второй проход стабилизации с использованием фильтра:
::     vidstabtransform
::
:: Назначение:
::   Применяет данные из .trf файла и создаёт
::   стабилизированное видео.
::
:: Требования:
::   - INPUT_FILE должен быть задан.
::   - transforms\{ИмяВидео}.trf должен существовать.
::
:: Официальная документация:
:: https://ffmpeg.org/ffmpeg-filters.html#vidstabtransform
:: ============================================================

:: ------------------------------------------------------------
:: Проверка конфигурации
:: ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: Проверка входного файла
:: ------------------------------------------------------------
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

:: ------------------------------------------------------------
:: Проверка поддержки vidstabtransform
:: ------------------------------------------------------------
"%FFMPEG%" -hide_banner -filters | findstr /i "vidstabtransform" >nul
if errorlevel 1 (
    echo.
    echo [ERROR] Фильтр vidstabtransform не найден.
    echo [ERROR] Требуется сборка FFmpeg с libvidstab.
    echo.
    pause
    exit /b 1
)

:: ------------------------------------------------------------
:: Определение имени файлов
:: ------------------------------------------------------------
for %%F in ("%INPUT_FILE%") do (
    set "INPUT_NAME=%%~nF"
    set "INPUT_EXT=%%~xF"
)

set "TRANSFORM_FILE=%TRANSFORMS_DIR%\%INPUT_NAME%.trf"

if not exist "%TRANSFORM_FILE%" (
    echo.
    echo [ERROR] Файл трансформации не найден:
    echo         %TRANSFORM_FILE%
    echo.
    echo Сначала выполните vidstabdetect.bat
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                   VidStab Transform
echo ============================================================
echo.
echo Входной файл:
echo %INPUT_FILE%
echo.
echo Файл трансформации:
echo %TRANSFORM_FILE%
echo.
echo ============================================================
echo.
echo  1. Быстрая стабилизация
echo  2. Стандартная стабилизация (рекомендуется)
echo  3. Максимально плавная стабилизация
echo  4. Пользовательские параметры
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите режим: "

if "%CHOICE%"=="1" goto PRESET_FAST
if "%CHOICE%"=="2" goto PRESET_STANDARD
if "%CHOICE%"=="3" goto PRESET_SMOOTH
if "%CHOICE%"=="4" goto CUSTOM_SETTINGS
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:: ============================================================
:: Пресеты
:: ============================================================
:PRESET_FAST
set "SMOOTHING=5"
set "ZOOM=0"
set "OPTZOOM=0"
set "ZOOMSPEED=0.25"
set "OPTALGO=gauss"
set "CROP=keep"
set "INTERPOL=linear"
set "RELATIVE=1"
set "MAXSHIFT=-1"
set "MAXANGLE=-1"
goto BUILD_FILTER


:PRESET_STANDARD
set "SMOOTHING=15"
set "ZOOM=0"
set "OPTZOOM=1"
set "ZOOMSPEED=0.25"
set "OPTALGO=gauss"
set "CROP=keep"
set "INTERPOL=bicubic"
set "RELATIVE=1"
set "MAXSHIFT=-1"
set "MAXANGLE=-1"
goto BUILD_FILTER


:PRESET_SMOOTH
set "SMOOTHING=30"
set "ZOOM=0"
set "OPTZOOM=2"
set "ZOOMSPEED=0.25"
set "OPTALGO=gauss"
set "CROP=black"
set "INTERPOL=bicubic"
set "RELATIVE=1"
set "MAXSHIFT=-1"
set "MAXANGLE=-1"
goto BUILD_FILTER


:: ============================================================
:: Пользовательские параметры
:: ============================================================
:CUSTOM_SETTINGS
cls

echo ============================================================
echo               Пользовательские параметры
echo ============================================================
echo.

:: Значения по умолчанию
set "SMOOTHING=15"
set "ZOOM=0"
set "OPTZOOM=1"
set "ZOOMSPEED=0.25"
set "OPTALGO=gauss"
set "CROP=keep"
set "INTERPOL=bicubic"
set "RELATIVE=1"
set "MAXSHIFT=-1"
set "MAXANGLE=-1"

set /p "SMOOTHING=Smoothing [15]: "
if not defined SMOOTHING set "SMOOTHING=15"

set /p "ZOOM=Manual Zoom (%%) [0]: "
if not defined ZOOM set "ZOOM=0"

echo.
echo Auto Zoom:
echo   0 = Off
echo   1 = Optimal
echo   2 = Aggressive
echo.
set /p "OPTZOOM=Optzoom [1]: "
if not defined OPTZOOM set "OPTZOOM=1"

set /p "ZOOMSPEED=Zoomspeed [0.25]: "
if not defined ZOOMSPEED set "ZOOMSPEED=0.25"

echo.
echo Optimization Algorithm:
echo   gauss
echo   avg
echo.
set /p "OPTALGO=Optalgo [gauss]: "
if not defined OPTALGO set "OPTALGO=gauss"

echo.
echo Crop Mode:
echo   keep  = сохранить размер кадра
echo   black = черные поля
echo.
set /p "CROP=Crop [keep]: "
if not defined CROP set "CROP=keep"

echo.
echo Interpolation:
echo   no
echo   linear
echo   bilinear
echo   bicubic
echo.
set /p "INTERPOL=Interpolation [bicubic]: "
if not defined INTERPOL set "INTERPOL=bicubic"

echo.
echo Relative:
echo   1 = использовать относительные значения
echo   0 = использовать абсолютные значения
echo.
set /p "RELATIVE=Relative [1]: "
if not defined RELATIVE set "RELATIVE=1"

set /p "MAXSHIFT=Max Shift (px) [-1]: "
if not defined MAXSHIFT set "MAXSHIFT=-1"

set /p "MAXANGLE=Max Angle (radians) [-1]: "
if not defined MAXANGLE set "MAXANGLE=-1"

goto BUILD_FILTER


:: ============================================================
:: Формирование фильтра
:: ============================================================
:BUILD_FILTER
set "VIDSTAB_FILTER=vidstabtransform=input='%TRANSFORM_FILE%':smoothing=%SMOOTHING%:zoom=%ZOOM%:optzoom=%OPTZOOM%:zoomspeed=%ZOOMSPEED%:optalgo=%OPTALGO%:crop=%CROP%:interpol=%INTERPOL%:relative=%RELATIVE%:maxshift=%MAXSHIFT%:maxangle=%MAXANGLE%"
goto RUN


:: ============================================================
:: Выполнение стабилизации
:: ============================================================
:RUN
cls

set "OUTPUT_EXT=%INPUT_EXT:~1%"
set "OUTPUT_SUFFIX=vidstab"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 goto MAIN_MENU

set "EDIT_ALLOW_AUDIO_COPY=1"
call "%SELECTORS_DIR%\select_edit_encode_profile.bat"
if errorlevel 1 goto MAIN_MENU

echo ============================================================
echo                  Применение стабилизации
echo ============================================================
echo.
echo Выходной файл:
echo %OUTPUT_FILE%
echo.
echo Фильтр:
echo %VIDSTAB_FILTER%
echo.
echo Нажмите любую клавишу для запуска...
echo.
pause >nul

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
-i "%INPUT_FILE%" ^
-vf "%VIDSTAB_FILTER%" ^
-c:v %EDIT_VIDEO_CODEC% %EDIT_VIDEO_OPTIONS% ^
-c:a %EDIT_AUDIO_CODEC% %EDIT_AUDIO_OPTIONS% ^
"%OUTPUT_FILE%"

if errorlevel 1 (
    echo.
    echo [ERROR] Стабилизация завершилась с ошибкой.
    echo.
    pause
    goto MAIN_MENU
)



:: ------------------------------------------------------------
:: Успешное завершение стабилизации
:: ------------------------------------------------------------
echo.
echo ============================================================
echo                        Готово
echo ============================================================
echo.
echo Стабилизированное видео:
echo %OUTPUT_FILE%
echo.

:: ------------------------------------------------------------
:: Сравнение исходного и стабилизированного видео
:: ------------------------------------------------------------
if "%HAS_FFPLAY%"=="1" (
    echo.
    set "COMPARE_RESULT="
    set /p "COMPARE_RESULT=Сравнить исходное и стабилизированное видео? (Y/N): "

    if /i "!COMPARE_RESULT!"=="Y" (
        start "Original" "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% ^
            -window_title "Original" ^
            "%INPUT_FILE%"

        start "Stabilized" "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% ^
            -window_title "Stabilized" ^
            "%OUTPUT_FILE%"
    )
)

:: ------------------------------------------------------------
:: Предложение удалить файл трансформации
:: ------------------------------------------------------------
echo.
set "DELETE_TRANSFORM="
set /p "DELETE_TRANSFORM=Удалить файл обработки трансформации (.trf)? (Y/N): "

if /i "!DELETE_TRANSFORM!"=="Y" (
    if exist "%TRANSFORM_FILE%" (
        del /q "%TRANSFORM_FILE%"

        if exist "%TRANSFORM_FILE%" (
            echo.
            echo [WARNING] Не удалось удалить файл:
            echo           %TRANSFORM_FILE%
        ) else (
            echo.
            echo Файл трансформации удален:
            echo %TRANSFORM_FILE%
        )
    ) else (
        echo.
        echo [INFO] Файл трансформации уже отсутствует.
    )
) else (
    echo.
    echo Файл трансформации сохранен:
    echo %TRANSFORM_FILE%
)

echo.
pause
goto MAIN_MENU

:: ============================================================
:: Выход
:: ============================================================
:EXIT_MODULE
endlocal
exit /b 0
