@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\edit.bat
rem Раздел "Редактирование". Контроллер операций modules\edit\*.bat.
rem
rem Каждая операция вызывается в отдельном setlocal: её переменные
rem не влияют на следующие операции. Перед операцией (кроме склейки)
rem выбирается входной файл.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Редактирование"
echo  --- Время ------------------------  --- Изображение ----------------
echo   1. Обрезка (trim)                   11. Цветокоррекция и LUT
echo   2. Склейка файлов                   12. Шумоподавление видео
echo   3. Скорость                         13. Резкость
echo   4. Реверс                           14. Деинтерлейсинг
echo   5. Частота кадров (FPS)             15. Появление / затухание
echo   6. Нарезка на сегменты              16. Стабилизация
echo.
echo  --- Кадр -------------------------  --- Наложение ------------------
echo   7. Поворот / отражение              17. Водяной знак (картинка)
echo   8. Масштабирование                  18. Текст
echo   9. Кадрирование (crop)              19. Вшить субтитры
echo  10. Поля до нужных пропорций (pad)
echo.
echo  --- Аудио ------------------------------------------------------
echo  20. Нормализация громкости (EBU R128)   23. Удалить аудио
echo  21. Громкость                           24. Шумоподавление аудио
echo  22. Заменить / добавить аудиодорожку
echo.
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите операцию"

set "OP="
if "%CHOICE%"=="1"  set "OP=trim"
if "%CHOICE%"=="2"  set "OP=concat"
if "%CHOICE%"=="3"  set "OP=speed"
if "%CHOICE%"=="4"  set "OP=reverse"
if "%CHOICE%"=="5"  set "OP=fps"
if "%CHOICE%"=="6"  set "OP=segment"
if "%CHOICE%"=="7"  set "OP=rotate"
if "%CHOICE%"=="8"  set "OP=resize"
if "%CHOICE%"=="9"  set "OP=crop"
if "%CHOICE%"=="10" set "OP=pad"
if "%CHOICE%"=="11" set "OP=color_correction"
if "%CHOICE%"=="12" set "OP=denoise"
if "%CHOICE%"=="13" set "OP=sharpen"
if "%CHOICE%"=="14" set "OP=deinterlace"
if "%CHOICE%"=="15" set "OP=fade"
if "%CHOICE%"=="16" set "OP=stabilization"
if "%CHOICE%"=="17" set "OP=overlay"
if "%CHOICE%"=="18" set "OP=drawtext"
if "%CHOICE%"=="19" set "OP=subtitles"
if "%CHOICE%"=="20" set "OP=loudnorm"
if "%CHOICE%"=="21" set "OP=volume"
if "%CHOICE%"=="22" set "OP=audio_replace"
if "%CHOICE%"=="23" set "OP=audio_remove"
if "%CHOICE%"=="24" set "OP=audio_denoise"

if "%CHOICE%"=="0" goto EXIT_MODULE
if not defined OP (
    call "%LIB%" :InvalidChoice
    goto MAIN_MENU
)

call :RunOperation "%OP%"
goto MAIN_MENU


rem ============================================================
rem :RunOperation имя
rem ============================================================
:RunOperation
set "OP_FILE=%MODULES_DIR%\edit\%~1.bat"
if not exist "%OP_FILE%" (
    echo [ERROR] Не найден модуль: %OP_FILE%
    pause
    exit /b 1
)
setlocal
set "EDIT_MODE=1"
if /i not "%~1"=="concat" (
    call "%SELECTORS_DIR%\select_input_file.bat"
    if errorlevel 1 (endlocal & exit /b 0)
)
call "%OP_FILE%"
endlocal
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
