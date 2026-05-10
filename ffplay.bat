@echo off


:MENU
cls
:: Установить жёлтый цвет текста для пунктов меню
color 0E
echo ========================================
echo              FFplay Player
echo ========================================
echo.
echo 1. Воспроизвести последний файл
echo 2. Воспроизвести без звука
echo 3. Воспроизвести без видео
echo 4. Тестовое видео
echo 5. Тестовый звук
echo 0. Назад
echo.


echo ----------------------------------------
echo Управление во время воспроизведения:
echo ----------------------------------------
echo Space      - Пауза / Продолжить
echo Left/Right - Перемотка на 10 секунд
echo Up/Down    - Перемотка на 1 минуту
echo M          - Вкл./выкл. звук
echo 9 / 0      - Уменьшить / увеличить громкость
echo F          - Полноэкранный режим
echo S          - Сделать скриншот кадра
echo Q          - Выход из плеера
echo Esc        - Выход из полноэкранного режима
echo.

set /p CHOICE=Выберите пункт: 


if "%CHOICE%"=="1" goto PLAY_LAST
if "%CHOICE%"=="2" goto PLAY_LAST_NO_AUDIO
if "%CHOICE%"=="3" goto PLAY_LAST_NO_VIDEO
if "%CHOICE%"=="4" goto TEST_VIDEO
if "%CHOICE%"=="5" goto TEST_AUDIO
if "%CHOICE%"=="0" exit /b

echo.
echo Некорректный выбор.
pause
goto MENU



:: Воспроизвести последний файл из папки OUTPUT_DIR, если он существует
:PLAY_LAST
call :GetLastOutputFile
if not defined INPUT_FILE 
goto MENU
"%FFPLAY%" -autoexit "%INPUT_FILE%"
pause
goto MENU


:: Воспроизвести последний файл без звука
:PLAY_LAST_NO_AUDIO
call :GetLastOutputFile
if not defined INPUT_FILE goto MENU
"%FFPLAY%" -an -autoexit "%INPUT_FILE%"
pause
goto MENU

 
 :: Воспроизвести последний файл без видео
:PLAY_LAST_NO_VIDEO
call :GetLastOutputFile
if not defined INPUT_FILE goto MENU
"%FFPLAY%" -vn -autoexit "%INPUT_FILE%"
pause
goto MENU



:: Воспроизвести тестовое видео
:TEST_VIDEO
"%FFPLAY%" -f lavfi -i "testsrc=size=1280x720:rate=30"
goto MENU



:: Воспроизвести тестовый звук  
:TEST_AUDIO
"%FFPLAY%" -f lavfi -i "sine=frequency=440:sample_rate=48000"
goto MENU


:: Запросить путь к файлу для воспроизведения
:AskFile
cls
set "INPUT_FILE="
set /p INPUT_FILE=Введите путь к файлу: 

if not defined INPUT_FILE 
exit /b



if not exist "%INPUT_FILE%" (
    echo.
    echo Файл не найден.
    pause
    set "INPUT_FILE="
)
exit /b


:: Получить последний файл из папки OUTPUT_DIR
:GetLastOutputFile
set "INPUT_FILE="

for /f "delims=" %%F in ('dir /b /a-d /o-d "%OUTPUT_DIR%" 2^>nul') do (
    set "INPUT_FILE=%OUTPUT_DIR%\%%F"
    goto :EOF
)

echo.
echo В папке "%OUTPUT_DIR%" нет файлов.
pause
exit /b