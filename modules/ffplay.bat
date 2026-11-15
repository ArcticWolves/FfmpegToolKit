@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\ffplay.bat
rem Проигрыватель FFplay: файлы, последний результат, визуализации,
rem тестовые сигналы и предпросмотр фильтров.
rem
rem Клавиши FFplay: q/Esc - выход, f - полный экран, p/пробел - пауза,
rem стрелки - перемотка, m - звук, w - режим отображения.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)
if not "%HAS_FFPLAY%"=="1" (echo [ERROR] ffplay.exe отсутствует. & pause & exit /b 1)

:MAIN_MENU
call "%LIB%" :Header "Проигрыватель FFplay"
echo   1. Открыть файл из input
echo   2. Последний результат из output
echo   3. Открыть файл: полный экран, повтор
echo   4. Аудио с визуализацией (волна / спектр)
echo   5. Предпросмотр фильтра (например hflip или eq=contrast=1.3)
echo   6. Тестовая таблица
echo   7. Тестовый тон 440 Гц
echo.
echo   q / Esc - выход из FFplay, f - полный экран, пробел - пауза
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
set "OPTS="
if "%CHOICE%"=="1" goto PLAY_INPUT
if "%CHOICE%"=="2" goto PLAY_LAST
if "%CHOICE%"=="3" (set "OPTS=-fs -loop 0" & goto PLAY_INPUT)
if "%CHOICE%"=="4" goto PLAY_VIS
if "%CHOICE%"=="5" goto PLAY_FILTER
if "%CHOICE%"=="6" (set "P_FILE=" & set "P_OPTS=-f lavfi testsrc2=size=1280x720:rate=30" & call :Play & goto MAIN_MENU)
if "%CHOICE%"=="7" (set "P_FILE=" & set "P_OPTS=-f lavfi sine=frequency=440:sample_rate=48000" & call :Play & goto MAIN_MENU)
if "%CHOICE%"=="0" goto EXIT_MODULE
call "%LIB%" :InvalidChoice
goto MAIN_MENU


:PLAY_INPUT
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto MAIN_MENU
set "P_FILE=!INPUT_FILE!"
set "P_OPTS=%OPTS%"
call :Play
goto MAIN_MENU

:PLAY_LAST
set "LAST="
for /f "delims=" %%F in ('dir /b /a-d /o-d "%OUTPUT_DIR%" 2^>nul') do if not defined LAST set "LAST=%OUTPUT_DIR%\%%F"
if not defined LAST (echo [INFO] Папка output пуста. & pause & goto MAIN_MENU)
echo Файл: !LAST!
set "P_FILE=!LAST!"
set "P_OPTS="
call :Play
goto MAIN_MENU

:PLAY_VIS
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto MAIN_MENU
call "%LIB%" :AskPick MODE "Режим: waves или rdft (спектр)" waves "waves rdft"
set "P_FILE=!INPUT_FILE!"
set "P_OPTS=-showmode %MODE%"
call :Play
goto MAIN_MENU

:PLAY_FILTER
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto MAIN_MENU
set "VF="
set /p "VF=Видеофильтр FFmpeg: "
if not defined VF goto MAIN_MENU
set "VF=!VF:"=!"
set "P_FILE=!INPUT_FILE!"
set "P_OPTS=-vf "!VF!""
call :Play
goto MAIN_MENU


rem ------------------------------------------------------------
rem :Play  - использует P_FILE (файл) и P_OPTS (параметры).
rem Если P_FILE пуст, P_OPTS содержит собственный вход (-f lavfi ...).
rem ------------------------------------------------------------
:Play
echo.
echo [INFO] Закройте окно FFplay (q или Esc), чтобы вернуться в меню.
if defined P_FILE (
    "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% !P_OPTS! "!P_FILE!"
) else (
    "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% !P_OPTS!
)
exit /b 0


:EXIT_MODULE
endlocal
exit /b 0
