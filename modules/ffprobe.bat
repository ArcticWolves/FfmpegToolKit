@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem ============================================================
rem modules\ffprobe.bat
rem Анализ медиафайлов через FFprobe.
rem Отчёты сохраняются в temp\logs.
rem ============================================================

if not defined CONFIG_LOADED (echo [ERROR] Запустите FFmpegToolkit.bat & pause & exit /b 1)

:SELECT
set "INPUT_TITLE=FFprobe: выбор файла"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 goto EXIT_MODULE

:MAIN_MENU
call "%LIB%" :Header "FFprobe"
echo Файл: !INPUT_FILE!
echo.
echo   1. Сводка: контейнер и все потоки
echo   2. Полный отчёт JSON (сохраняется в temp\logs)
echo   3. Точное количество кадров (медленно)
echo   4. Ключевые кадры (время)
echo   5. Главы
echo   6. Громкость (EBU R128: LUFS, пики)
echo   7. Сравнить с другим файлом
echo   8. Выбрать другой файл
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите действие"
if "%CHOICE%"=="1" (call :Summary "!INPUT_FILE!" & pause & goto MAIN_MENU)
if "%CHOICE%"=="2" goto FULL_JSON
if "%CHOICE%"=="3" goto FRAME_COUNT
if "%CHOICE%"=="4" goto KEYFRAMES
if "%CHOICE%"=="5" goto CHAPTERS
if "%CHOICE%"=="6" goto LOUDNESS
if "%CHOICE%"=="7" goto COMPARE
if "%CHOICE%"=="8" goto SELECT
if "%CHOICE%"=="0" goto EXIT_MODULE
call "%LIB%" :InvalidChoice
goto MAIN_MENU


rem ------------------------------------------------------------
rem :Summary "файл" - читаемая сводка
rem ------------------------------------------------------------
:Summary
echo.
echo ---------------- Контейнер ----------------
"%FFPROBE%" -v error -show_entries format=format_long_name,duration,size,bit_rate:format_tags=title,encoder,creation_time -of default=noprint_wrappers=1 "%~1"
echo.
echo ---------------- Потоки -------------------
"%FFPROBE%" -v error -show_entries stream=index,codec_type,codec_name,profile,width,height,pix_fmt,r_frame_rate,sample_rate,channels,channel_layout,bit_rate:stream_tags=language,title -of compact=p=0:nk=0 "%~1"
echo.
exit /b 0


:FULL_JSON
for %%F in ("%INPUT_FILE%") do set "REPORT=%LOG_DIR%\%%~nF_ffprobe.json"
"%FFPROBE%" -v error -print_format json -show_format -show_streams -show_chapters "%INPUT_FILE%" > "%REPORT%"
if errorlevel 1 (echo [ERROR] FFprobe завершился с ошибкой. & pause & goto MAIN_MENU)
echo.
echo Сохранено: %REPORT%
call "%LIB%" :AskYN "Открыть в Блокноте?" N
if not errorlevel 1 start "" notepad "%REPORT%"
goto MAIN_MENU


:FRAME_COUNT
echo.
echo Подсчёт кадров (файл читается целиком)...
call "%LIB%" :Probe FRAMES "-count_frames -select_streams v:0 -show_entries stream=nb_read_frames" "%INPUT_FILE%"
if not defined FRAMES set "FRAMES=нет видео"
echo Кадров: %FRAMES%
pause
goto MAIN_MENU


:KEYFRAMES
for %%F in ("%INPUT_FILE%") do set "REPORT=%LOG_DIR%\%%~nF_keyframes.txt"
echo.
echo Поиск ключевых кадров...
"%FFPROBE%" -v error -select_streams v:0 -skip_frame nokey -show_entries frame=pts_time -of csv=p=0 "%INPUT_FILE%" > "%REPORT%"
set "KCOUNT=0"
for /f "usebackq delims=" %%L in ("%REPORT%") do set /a KCOUNT+=1
echo Ключевых кадров: %KCOUNT%
echo Список времён сохранён: %REPORT%
pause
goto MAIN_MENU


:CHAPTERS
echo.
"%FFPROBE%" -v error -show_entries chapter=start_time,end_time:chapter_tags=title -of compact=p=0 "%INPUT_FILE%"
echo (если список пуст - глав в файле нет)
pause
goto MAIN_MENU


:LOUDNESS
echo.
echo Измерение громкости (EBU R128)...
"%FFMPEG%" -hide_banner -nostats -i "%INPUT_FILE%" -map 0:a:0 -af ebur128=peak=true -f null - 2> "%TEMP_DIR%\ebur128.txt"
set "PRINT="
for /f "usebackq delims=" %%L in ("%TEMP_DIR%\ebur128.txt") do (
    set "_l=%%L"
    if "!_l:Summary=!" neq "!_l!" set "PRINT=1"
    if defined PRINT echo %%L
)
if not defined PRINT echo [ERROR] В файле нет аудио или измерение не удалось.
echo.
echo Integrated (I) - средняя громкость: YouTube/Spotify ~ -14 LUFS.
echo Нормализовать: Редактирование - Нормализация громкости.
pause
goto MAIN_MENU


:COMPARE
set "FIRST=%INPUT_FILE%"
set "INPUT_TITLE=Второй файл для сравнения"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 (set "INPUT_FILE=%FIRST%" & goto MAIN_MENU)
set "SECOND=%INPUT_FILE%"
set "INPUT_FILE=%FIRST%"
cls
echo ================= ФАЙЛ 1 =================
echo %FIRST%
call :Summary "%FIRST%"
echo ================= ФАЙЛ 2 =================
echo %SECOND%
call :Summary "%SECOND%"
pause
goto MAIN_MENU


:EXIT_MODULE
endlocal
exit /b 0
