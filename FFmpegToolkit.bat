@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

:: ============================================================
:: FfmpegToolKit.bat
::
:: Главная точка входа в FFmpeg ToolKit.
:: Отвечает только за:
::   1. Загрузку конфигурации.
::   2. Отображение главного меню.
::   3. Вызов соответствующих модулей.
::
:: Архитектурная роль: Application Controller
:: ============================================================


:: ------------------------------------------------------------
:: Загрузка глобальной конфигурации
:: ------------------------------------------------------------
call "%~dp0config.bat"
if errorlevel 1 (exit /b 1)


:: ------------------------------------------------------------
:: Проверка успешной загрузки конфигурации
:: ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] config.bat не был успешно загружен.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                     FFmpeg ToolKit
echo ============================================================
echo.
echo Версия FFmpeg : %FFMPEG_VERSION%
echo Корень проекта: %ROOT%
echo.
echo ============================================================
echo.
echo  1. Проигрыватель  (FFplay)
echo  2. Анализатор     (FFprobe)
echo  3. Обработка      (FFmpeg)
echo  4. Информация     (FFmpeg build)
echo  5. Поиск          (кодеки / фильтры)
echo.
echo  0. Выход
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto MENU_FFPLAY
if "%CHOICE%"=="2" goto MENU_FFPROBE
if "%CHOICE%"=="3" goto MENU_FFMPEG
if "%CHOICE%"=="4" goto MENU_INFO
if "%CHOICE%"=="5" goto MENU_SEARCH
if "%CHOICE%"=="0" goto EXIT_APP

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


:: ============================================================
:: FFPLAY
:: ============================================================
:MENU_FFPLAY

if "%HAS_FFPLAY%"=="0" (
    echo.
    echo [ERROR] ffplay.exe отсутствует в сборке.
    echo.
    pause
    goto MAIN_MENU
)

call "%ROOT%\ffplay.bat"
goto MAIN_MENU


:: ============================================================
:: FFPROBE
:: ============================================================
:MENU_FFPROBE
call :RunModule "ffprobe.bat"
goto MAIN_MENU


:: ============================================================
:: FFMPEG
:: ============================================================
:MENU_FFMPEG
call :RunModule "ffmpeg.bat"
goto MAIN_MENU


:: ============================================================
:: INFO
:: ============================================================
:MENU_INFO
call :RunModule "info.bat"
goto MAIN_MENU


:: ============================================================
:: SEARCH
:: ============================================================
:MENU_SEARCH
call :RunModule "search.bat"
goto MAIN_MENU


:: ============================================================
:: Универсальный запуск модуля
:: Аргумент:
::   %~1 = имя bat-файла в каталоге modules
:: ============================================================
:RunModule
set "MODULE_PATH=%MODULES_DIR%\%~1"

if not exist "%MODULE_PATH%" (
    echo.
    echo [ERROR] Не найден модуль:
    echo         %MODULE_PATH%
    echo.
    pause
    exit /b 1
)

call "%MODULE_PATH%"
exit /b 0


:: ============================================================
:: Завершение приложения
:: ============================================================
:EXIT_APP
cls
echo ============================================================
echo               Завершение работы
echo ============================================================
echo.
echo Спасибо за использование FFmpeg ToolKit.
echo.

endlocal
exit /b 0
