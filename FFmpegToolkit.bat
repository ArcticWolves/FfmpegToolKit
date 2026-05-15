@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul

:: Загрузка конфигурации и проверка наличия FFmpeg
call config.bat
if errorlevel 1 goto EXIT



:MENU
cls
:: Установка цвета консоли (синего текста на черном фоне)
color 03
echo ========================================
echo        FFmpeg Console Wrapper
echo ========================================
echo.
echo 1. Информация FFmpeg
echo 2. Поиск компонентов
echo 3. Конвертация
echo 4. Извлечение
echo 5. Редактирование
echo 6. Пакетная обработка
echo 7. Пресеты
echo 8. Анализ файла (FFprobe)
echo 9. Проигрыватель (FFplay)
echo 0. Выход
echo.

set /p CHOICE=Выберите пункт:

:: Вернуть стандартный цвет (светло-серый на чёрном фоне)
color 07 


if "%CHOICE%"=="1" (
    call modules\info.bat 
    goto MENU
    )

if "%CHOICE%"=="2" (
    call modules\search.bat
    goto MENU
    )

if "%CHOICE%"=="3" (
    call modules\convert.bat
    goto MENU
    )

if "%CHOICE%"=="4" (
    call modules\extract.bat
    goto MENU
    )

if "%CHOICE%"=="5" (
    call modules\edit.bat
    goto MENU
    )

if "%CHOICE%"=="6" (
    call modules\batch.bat
    goto MENU
    )

if "%CHOICE%"=="7" (
    call modules\presets.bat
    goto MENU
    )

if "%CHOICE%"=="8" (    
    call modules\ffprobe.bat
    goto MENU
    )

if "%CHOICE%"=="9" (
    call ffplay.bat
    goto MENU
    )

if "%CHOICE%"=="0" goto EXIT

echo.
echo Некорректный выбор.
pause
goto MENU

:EXIT
endlocal
exit /b