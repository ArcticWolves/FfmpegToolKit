@echo off
rem ============================================================
rem modules\tools\whisper.bat
rem Распознавание речи в субтитры (.srt) фильтром whisper (whisper.cpp).
rem ============================================================

if not defined HAS_FLT_whisper (echo [ERROR] Фильтр whisper отсутствует в этой сборке FFmpeg. & pause & exit /b 0)
call "%LIB%" :Header "Субтитры из речи (Whisper)"

rem Модель: первый файл ggml-*.bin в папке models
set "MODEL="
for /f "delims=" %%M in ('dir /b /a-d /on "%MODELS_DIR%\ggml-*.bin" 2^>nul') do (
    if not defined MODEL set "MODEL=%MODELS_DIR%\%%M"
)
if not defined MODEL (
    echo Нужна модель whisper.cpp в папке:
    echo   %MODELS_DIR%
    echo.
    echo Скачайте, например, ggml-base.bin ^(~150 МБ, хороший баланс^)
    echo или ggml-small.bin ^(точнее, ~500 МБ^) отсюда:
    echo   https://huggingface.co/ggerganov/whisper.cpp/tree/main
    echo и положите файл в папку models.
    echo.
    pause
    exit /b 0
)
echo Модель: %MODEL%
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
call "%LIB%" :ProbeInput
if not "%IN_HAS_AUDIO%"=="1" (echo [ERROR] В файле нет аудио. & pause & exit /b 0)
call "%LIB%" :Ask LANG "Язык речи: ru, en, uk, de... или auto" "auto"

set "OUTPUT_EXT=srt"
set "OUTPUT_SUFFIX=whisper"
call "%SELECTORS_DIR%\select_output_file.bat"
if errorlevel 1 exit /b 0

set "MODEL_F=%MODEL%"
call "%LIB%" :FilterPath MODEL_F
rem Фильтр пишет во временный файл с безопасным путём, затем файл
rem переносится в output под выбранным именем.
set "TMP_SRT=%TEMP_DIR%\whisper_out.srt"
if exist "%TMP_SRT%" del /q "%TMP_SRT%"
set "OUT_F=%TMP_SRT%"
call "%LIB%" :FilterPath OUT_F
rem Whisper работает с моно 16 кГц - преобразование делает сам фильтр
set "FF_ARGS=-i "!INPUT_FILE!" -vn -af "whisper=model='!MODEL_F!':language=%LANG%:queue=20:destination='!OUT_F!':format=srt" -f null -"
echo.
echo На слабых ПК распознавание идёт медленнее реального времени.
call "%LIB%" :AskYN "Запустить распознавание?" Y
if errorlevel 1 exit /b 0
call "%LIB%" :RunFF
if errorlevel 1 (echo [ERROR] Распознавание не удалось. & pause & exit /b 1)
if not exist "%TMP_SRT%" (echo [ERROR] Файл субтитров не создан. & pause & exit /b 1)
move /y "%TMP_SRT%" "%OUTPUT_FILE%" >nul
echo.
echo Готово: !OUTPUT_FILE!
echo Субтитры можно вшить или добавить дорожкой: Редактирование - Субтитры.
call "%LIB%" :OfferOpen "!OUTPUT_FILE!"
