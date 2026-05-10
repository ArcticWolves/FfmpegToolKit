@echo off

:MENU
cls
echo 1. Версия FFmpeg
echo 2. Build Configuration
echo 3. Кодеки
echo 4. Энкодеры
echo 5. Декодеры
echo 6. Фильтры
echo 7. Аппаратные ускорители
echo 0. Назад
echo.

set /p CHOICE=Выберите пункт:

if "%CHOICE%"=="1" (
    "%FFMPEG%" -version
    pause
    goto MENU
)

if "%CHOICE%"=="2" (
    "%FFMPEG%" -buildconf
    pause
    goto MENU
)

if "%CHOICE%"=="3" (
    "%FFMPEG%" -codecs
    pause
    goto MENU
)

if "%CHOICE%"=="4" (
    "%FFMPEG%" -encoders
    pause
    goto MENU
)

if "%CHOICE%"=="5" (
    "%FFMPEG%" -decoders
    pause
    goto MENU
)

if "%CHOICE%"=="6" (
    "%FFMPEG%" -filters
    pause
    goto MENU
)

if "%CHOICE%"=="7" (
    "%FFMPEG%" -hwaccels
    pause
    goto MENU
)

if "%CHOICE%"=="0" exit /b


:: Если выбор не распознан, показать сообщение об ошибке
echo.
echo Некорректный выбор.
pause
goto MENU
