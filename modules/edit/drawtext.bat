@echo off
rem ============================================================
rem modules\edit\drawtext.bat
rem Наложение текста или таймкода на видео.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

if not defined HAS_FLT_drawtext (echo [ERROR] Фильтр drawtext отсутствует в сборке. & pause & exit /b 1)
call "%LIB%" :Header "Текст на видео"
echo   1. Свой текст   [Enter]
echo   2. Таймкод (ЧЧ:ММ:СС)
echo   3. Номер кадра
call "%LIB%" :AskChoice "Что показать"
set "MODE=%CHOICE%"
if not defined MODE set "MODE=1"

rem Текст пишется во временный файл без перевода строки (textfile=...):
rem так любые символы (кавычки, двоеточия, кириллица) не требуют
rem экранирования в фильтре.
set "TEXT_FILE=%TEMP_DIR%\drawtext.txt"
set "EXPANSION=none"
if "%MODE%"=="1" (
    set "TEXT="
    set /p "TEXT=Текст: "
    if not defined TEXT exit /b 0
    <nul set /p "=!TEXT!" > "!TEXT_FILE!"
)
if "%MODE%"=="2" (
    <nul set /p "=%%{pts:hms}" > "!TEXT_FILE!"
    set "EXPANSION=normal"
)
if "%MODE%"=="3" (
    <nul set /p "=%%{frame_num}" > "!TEXT_FILE!"
    set "EXPANSION=normal"
)

set "FONT=C:\Windows\Fonts\arial.ttf"
echo.
echo Шрифт по умолчанию: %FONT%
set "FONT_IN="
set /p "FONT_IN=Другой файл шрифта (Enter = по умолчанию): "
if defined FONT_IN (
    set "FONT_IN=!FONT_IN:"=!"
    if exist "!FONT_IN!" (set "FONT=!FONT_IN!") else (echo [WARN] Файл не найден, используется Arial.)
)

call "%LIB%" :AskInt SIZE "Размер шрифта" 48 6 500
call "%LIB%" :Ask COLOR "Цвет текста (white, yellow, #FF8800...)" "white"
call "%LIB%" :AskInt BORDER "Обводка, пикселей (0 = нет)" 2 0 50
call "%LIB%" :AskYN "Подложка под текстом?" N
if errorlevel 1 (set "BOX=0") else (set "BOX=1")

echo.
echo Позиция:
echo   1. Слева сверху     2. Сверху по центру    3. Справа сверху
echo   4. Слева снизу      5. Снизу по центру     6. Справа снизу
echo   7. По центру   [Enter = 5]
call "%LIB%" :AskChoice "Позиция"
set "X=(w-text_w)/2" & set "Y=h-text_h-40"
if "%CHOICE%"=="1" (set "X=40" & set "Y=40")
if "%CHOICE%"=="2" (set "X=(w-text_w)/2" & set "Y=40")
if "%CHOICE%"=="3" (set "X=w-text_w-40" & set "Y=40")
if "%CHOICE%"=="4" (set "X=40" & set "Y=h-text_h-40")
if "%CHOICE%"=="6" (set "X=w-text_w-40" & set "Y=h-text_h-40")
if "%CHOICE%"=="7" (set "X=(w-text_w)/2" & set "Y=(h-text_h)/2")

call "%LIB%" :AskTime T_START "Показывать с (секунды, Enter = всё время)" ""
set "T_END="
if defined T_START call "%LIB%" :AskTime T_END "Показывать до (секунды)" ""

set "FONT_F=%FONT%"
call "%LIB%" :FilterPath FONT_F
set "TEXT_F=%TEXT_FILE%"
call "%LIB%" :FilterPath TEXT_F

set "VIDEO_FILTER=drawtext=fontfile='!FONT_F!':textfile='!TEXT_F!':expansion=%EXPANSION%:fontsize=%SIZE%:fontcolor=%COLOR%:borderw=%BORDER%:bordercolor=black:box=%BOX%:boxcolor=black@0.5:boxborderw=12:x=!X!:y=!Y!"
if defined T_END set "VIDEO_FILTER=!VIDEO_FILTER!:enable='between(t,%T_START%,%T_END%)'"

set "OUTPUT_SUFFIX=text"
set "JOB_TITLE=Текст на видео"
call "%TRANSCODE%"
