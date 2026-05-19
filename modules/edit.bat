@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

rem ============================================================
rem modules\edit.bat
rem
rem Раздел "Редактирование".
rem
rem Назначение:
rem   Отображает меню операций редактирования и передаёт
rem   управление специализированным подмодулям.
rem
rem Архитектурная роль:
rem   Controller.
rem
rem Структура раздела:
rem   modules\
rem       edit.bat
rem       edit\
rem           trim.bat
rem           concat.bat
rem           speed.bat
rem           rotate.bat
rem           resize.bat
rem           overlay.bat
rem           stabilization.bat
rem           filters\
rem               color_correction.bat
rem               color_equalizer.bat
rem               color_hue.bat
rem ============================================================

rem ------------------------------------------------------------
rem Проверка загрузки конфигурации
rem ------------------------------------------------------------
if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FfmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

:MAIN_MENU
cls

echo ============================================================
echo                      Редактирование
echo ============================================================
echo.
echo  1. Обрезка по времени (Trim)
echo  2. Склейка (Concat)
echo  3. Изменение скорости
echo  4. Поворот
echo  5. Изменение размера (Resolution)
echo  6. Наложение изображения или видео (Overlay)
echo  7. Цветокоррекция
echo  8. Стабилизация
echo  9. Обрезка области (Crop)
echo.
echo  0. Назад
echo.
echo ============================================================
echo.

set "CHOICE="
set /p "CHOICE=Выберите действие: "

if "%CHOICE%"=="1" goto MENU_TRIM
if "%CHOICE%"=="2" goto MENU_CONCAT
if "%CHOICE%"=="3" goto MENU_SPEED
if "%CHOICE%"=="4" goto MENU_ROTATE
if "%CHOICE%"=="5" goto MENU_RESIZE
if "%CHOICE%"=="6" goto MENU_OVERLAY
if "%CHOICE%"=="7" goto MENU_COLOR_CORRECTION
if "%CHOICE%"=="8" goto MENU_STABILIZATION
if "%CHOICE%"=="0" goto EXIT_MODULE

echo.
echo [ERROR] Некорректный выбор.
echo.
pause
goto MAIN_MENU


rem ============================================================
rem 1. Обрезка
rem ============================================================
:MENU_TRIM
call :RunModule "edit\trim.bat"
goto MAIN_MENU


rem ============================================================
rem 2. Склейка
rem ============================================================
:MENU_CONCAT
call :RunModule "edit\concat.bat"
goto MAIN_MENU


rem ============================================================
rem 3. Изменение скорости
rem ============================================================
:MENU_SPEED
call :RunModule "edit\speed.bat"
goto MAIN_MENU


rem ============================================================
rem 4. Поворот
rem ============================================================
:MENU_ROTATE
call :RunModule "edit\rotate.bat"
goto MAIN_MENU


rem ============================================================
rem 5. Изменение размера
rem ============================================================
:MENU_RESIZE
call :RunModule "edit\resize.bat"
goto MAIN_MENU


rem ============================================================
rem 6. Наложение изображения или видео (Overlay)
rem ============================================================
:MENU_OVERLAY
call :RunModule "edit\overlay.bat"
goto MAIN_MENU


rem ============================================================
rem 7. Цветокоррекция
rem ============================================================
:MENU_COLOR_CORRECTION
call :RunModule "edit\filters\color_correction.bat"
goto MAIN_MENU


rem ============================================================
rem 8. Стабилизация
rem ============================================================
:MENU_STABILIZATION
call :RunModule "edit\stabilization.bat"
goto MAIN_MENU


rem ============================================================
rem Универсальный запуск модуля
rem
rem Аргумент:
rem   %~1 - относительный путь внутри %MODULES_DIR%
rem
rem Пример:
rem   call :RunModule "edit\concat.bat"
rem ============================================================
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


rem ============================================================
rem Выход из раздела
rem ============================================================
:EXIT_MODULE
endlocal
exit /b 0