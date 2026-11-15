@echo off
rem ============================================================================
rem lib\common.bat
rem Общая библиотека подпрограмм FFmpeg ToolKit.
rem
rem Вызов:
rem   call "%LIB%" :Имя аргументы...
rem
rem Подпрограммы работают в окружении вызывающего скрипта (setlocal здесь
rem нет), поэтому могут возвращать значения через переменные.
rem
rem Ввод пользователя
rem   :Header      "Заголовок"                    очистить экран и вывести заголовок
rem   :AskChoice   "Подсказка"                    -> CHOICE (без кавычек и спецсимволов)
rem   :Ask         VAR "Подсказка" "по умолчанию" строка
rem   :AskInt      VAR "Подсказка" def min max    целое число в диапазоне
rem   :AskNum      VAR "Подсказка" def            число (допускается дробь и минус)
rem   :AskTime     VAR "Подсказка" def            таймкод 00:01:23.5 или секунды
rem   :AskPick     VAR "Подсказка" def "a b c"    одно из перечисленных слов
rem   :AskBitrate  VAR "Подсказка" def            битрейт: 192k, 5M, 800000
rem   :AskYN       "Вопрос" Y|N                   errorlevel 0 = да, 1 = нет
rem   :AskFile     VAR "Подсказка"                путь к существующему файлу
rem
rem Проверки
rem   :IsInt "значение"   :IsNum "значение"   :IsTime "значение"
rem   :IsMediaFile "путь"                       по расширению из MEDIA_EXTENSIONS
rem   :RequireInput                             INPUT_FILE задан и существует
rem
rem Кодеки
rem   :IsAvailable энкодер                      есть ли энкодер в сборке
rem   :PickBest    VAR "список энкодеров"       первый доступный
rem
rem FFmpeg
rem   :ProbeInput                               IN_HAS_VIDEO, IN_HAS_AUDIO,
rem                                             IN_HAS_SUBS, IN_DURATION, IN_WIDTH,
rem                                             IN_HEIGHT, IN_VCODEC, IN_ACODEC
rem   :Probe       VAR "аргументы ffprobe" "файл"  первое значение
rem   :FilterPath  VAR                          путь -> безопасный для filtergraph
rem   :RunFF                                    выполнить ffmpeg с FF_ARGS (+ журнал)
rem   :RunJob                                   подтверждение + RunFF + результат
rem   :OfferOpen   "файл"                       открыть в FFplay или в проводнике
rem   :ResetJob                                 очистить параметры движка transcode
rem
rem Прочее
rem   :Timestamp   VAR                          метка времени для имён файлов
rem   :ToMilli     VAR "1.25"                   десятичное -> целое (тысячные)
rem   :FromMilli   VAR 1250                     целое (тысячные) -> "1.250"
rem   :InvalidChoice                            сообщение о неверном выборе
rem ============================================================================

call %*
exit /b %errorlevel%


rem ============================================================================
rem Экран
rem ============================================================================
:Header
cls
echo ============================================================
echo   %~1
echo ============================================================
echo.
exit /b 0

:InvalidChoice
echo.
echo [ERROR] Некорректный выбор.
echo.
pause
exit /b 0


rem ============================================================================
rem Ввод
rem ============================================================================

rem :AskChoice "Подсказка" -> CHOICE
:AskChoice
set "CHOICE="
set /p "CHOICE=%~1: "
call :Sanitize CHOICE
exit /b 0

rem :Sanitize VAR — убрать кавычки и символы, ломающие cmd
:Sanitize
setlocal EnableDelayedExpansion
set "_s=!%~1!"
if not defined _s (endlocal & set "%~1=" & exit /b 0)
set "_s=!_s:"=!"
set "_s=!_s:&=!"
set "_s=!_s:|=!"
set "_s=!_s:<=!"
set "_s=!_s:>=!"
set "_s=!_s:^=!"
set "_s=!_s:(=!"
set "_s=!_s:)=!"
set "_s=!_s:%%=!"
if not defined _s (endlocal & set "%~1=" & exit /b 0)
endlocal & set "%~1=%_s%"
exit /b 0

rem :Ask VAR "Подсказка" "по умолчанию"
:Ask
set "_ask="
if "%~3"=="" (
    set /p "_ask=%~2: "
) else (
    set /p "_ask=%~2 [%~3]: "
)
if not defined _ask set "_ask=%~3"
if defined _ask set "_ask=%_ask:"=%"
set "%~1=%_ask%"
set "_ask="
exit /b 0

rem :AskInt VAR "Подсказка" def min max
:AskInt
call :Ask %1 %2 %3
call set "_ai=%%%~1%%"
call :IsInt "%_ai%"
if errorlevel 1 (echo [ERROR] Нужно целое число. & goto AskInt)
if %_ai% LSS %~4 (echo [ERROR] Минимум: %~4 & goto AskInt)
if %_ai% GTR %~5 (echo [ERROR] Максимум: %~5 & goto AskInt)
set "_ai="
exit /b 0

rem :AskNum VAR "Подсказка" def
:AskNum
call :Ask %1 %2 %3
call set "_an=%%%~1%%"
call :IsNum "%_an%"
if errorlevel 1 (echo [ERROR] Нужно число, например 1.5 & goto AskNum)
set "_an="
exit /b 0

rem :AskTime VAR "Подсказка" def   (пустое значение допустимо, если def пуст)
:AskTime
call :Ask %1 %2 %3
call set "_at=%%%~1%%"
if not defined _at if "%~3"=="" exit /b 0
call :IsTime "%_at%"
if errorlevel 1 (echo [ERROR] Формат: 00:01:23.500 или число секунд & goto AskTime)
set "_at="
exit /b 0

rem :AskPick VAR "Подсказка" def "слово1 слово2 ..."
:AskPick
call :Ask %1 %2 %3
call set "_ap=%%%~1%%"
for %%W in (%~4) do if /i "%%W"=="%_ap%" (set "%~1=%%W" & set "_ap=" & exit /b 0)
echo [ERROR] Допустимые значения: %~4
goto AskPick

rem :AskBitrate VAR "Подсказка" def
:AskBitrate
call :Ask %1 %2 %3
call set "_ab=%%%~1%%"
if not defined _ab goto AskBitrate
set "_ab2=%_ab:~0,-1%"
for %%S in (k K m M) do if "%_ab:~-1%"=="%%S" set "_ab=%_ab2%"
call :IsInt "%_ab%"
if errorlevel 1 (echo [ERROR] Формат битрейта: 192k, 5M или 800000 & goto AskBitrate)
set "_ab=" & set "_ab2="
exit /b 0

rem :AskYN "Вопрос" Y|N  ->  errorlevel 0 = да
:AskYN
set "_yn="
set "_ynp=y/N"
if /i "%~2"=="Y" set "_ynp=Y/n"
set /p "_yn=%~1 (%_ynp%): "
if not defined _yn set "_yn=%~2"
set "_yn=%_yn:"=%"
if /i "%_yn%"=="Y" goto AskYN_Yes
if /i "%_yn%"=="yes" goto AskYN_Yes
if "%_yn%"=="1" goto AskYN_Yes
if "%_yn%"=="Д" goto AskYN_Yes
if "%_yn%"=="д" goto AskYN_Yes
set "_yn="
exit /b 1
:AskYN_Yes
set "_yn="
exit /b 0

rem :AskFile VAR "Подсказка"  (пустой ввод = отмена, errorlevel 1)
:AskFile
set "_af="
set /p "_af=%~2 (Enter = отмена): "
if not defined _af (set "%~1=" & exit /b 1)
set "_af=%_af:"=%"
if not exist "%_af%" (echo [ERROR] Файл не найден: %_af% & goto AskFile)
for %%F in ("%_af%") do set "%~1=%%~fF"
set "_af="
exit /b 0


rem ============================================================================
rem Проверки значений
rem ============================================================================
:IsInt
set "_t=%~1"
if not defined _t exit /b 1
if "%_t:~0,1%"=="-" set "_t=%_t:~1%"
if not defined _t exit /b 1
for /f "delims=0123456789" %%A in ("%_t%") do exit /b 1
exit /b 0

:IsNum
set "_t=%~1"
if not defined _t exit /b 1
if "%_t:~0,1%"=="-" set "_t=%_t:~1%"
if not defined _t exit /b 1
for /f "tokens=4 delims=." %%A in (".%_t%.x") do exit /b 1
set "_t=%_t:.=%"
if not defined _t exit /b 1
for /f "delims=0123456789" %%A in ("%_t%") do exit /b 1
exit /b 0

:IsTime
set "_t=%~1"
if not defined _t exit /b 1
for /f "delims=0123456789:." %%A in ("%_t%") do exit /b 1
exit /b 0

:IsMediaFile
for %%X in (%MEDIA_EXTENSIONS%) do if /i "%%X"=="%~x1" exit /b 0
exit /b 1

:RequireInput
if not defined INPUT_FILE (
    echo.
    echo [ERROR] Входной файл не выбран.
    echo.
    pause
    exit /b 1
)
if not exist "%INPUT_FILE%" (
    echo.
    echo [ERROR] Входной файл не найден:
    echo         !INPUT_FILE!
    echo.
    pause
    exit /b 1
)
exit /b 0


rem ============================================================================
rem Кодеки
rem ============================================================================
:IsAvailable
if /i "%~1"=="copy" exit /b 0
if defined HAS_ENC_%~1 exit /b 0
exit /b 1

:PickBest
for %%E in (%~2) do (
    if /i "%%E"=="copy" (set "%~1=copy" & exit /b 0)
    if defined HAS_ENC_%%E (set "%~1=%%E" & exit /b 0)
)
set "%~1="
exit /b 1


rem ============================================================================
rem FFprobe
rem Вывод пишется во временный файл: так пути с запятыми, "=" и пробелами
rem обрабатываются корректно (в for /f ('команда') они ломаются).
rem ============================================================================

rem :Probe VAR "аргументы" "файл"
:Probe
set "%~1="
"%FFPROBE%" -v error %~2 -of default=noprint_wrappers=1:nokey=1 "%~3" > "%TEMP_DIR%\probe.tmp" 2>nul
for /f "usebackq delims=" %%L in ("%TEMP_DIR%\probe.tmp") do (
    set "%~1=%%L"
    goto ProbeDone
)
:ProbeDone
del /q "%TEMP_DIR%\probe.tmp" >nul 2>&1
exit /b 0

:ProbeInput
set "IN_HAS_VIDEO=0"
set "IN_HAS_AUDIO=0"
set "IN_HAS_SUBS=0"
call :Probe IN_VCODEC   "-select_streams v:0 -show_entries stream=codec_name" "%INPUT_FILE%"
call :Probe IN_ACODEC   "-select_streams a:0 -show_entries stream=codec_name" "%INPUT_FILE%"
call :Probe _subs       "-select_streams s:0 -show_entries stream=codec_name" "%INPUT_FILE%"
call :Probe IN_WIDTH    "-select_streams v:0 -show_entries stream=width"      "%INPUT_FILE%"
call :Probe IN_HEIGHT   "-select_streams v:0 -show_entries stream=height"     "%INPUT_FILE%"
call :Probe IN_DURATION "-show_entries format=duration"                       "%INPUT_FILE%"
if defined IN_VCODEC set "IN_HAS_VIDEO=1"
if defined IN_ACODEC set "IN_HAS_AUDIO=1"
if defined _subs set "IN_HAS_SUBS=1"
set "_subs="
exit /b 0


rem ============================================================================
rem :FilterPath VAR
rem Делает путь безопасным для значения опции фильтра в одинарных кавычках:
rem   C:\Dir\file.cube  ->  C\:/Dir/file.cube
rem Использование:  lut3d=file='%PATH_VAR%'
rem Пути с апострофом нельзя передать в фильтр, поэтому файл копируется
rem во временную папку под безопасным именем.
rem ============================================================================
:FilterPath
setlocal EnableDelayedExpansion
call set "_p=%%%~1%%"
set "_x="
for %%F in ("%_p%") do set "_x=%%~xF"
if not "!_p!"=="!_p:'=!" (
    copy /y "!_p!" "!TEMP_DIR!\filter_input!_x!" >nul
    set "_p=!TEMP_DIR!\filter_input!_x!"
)
set "_p=!_p:\=/!"
set "_p=!_p::=\:!"
endlocal & set "%~1=%_p%"
exit /b 0


rem ============================================================================
rem :RunFF
rem Выполняет: ffmpeg FFMPEG_GLOBAL_OPTIONS FF_ARGS
rem Команда выводится на экран и пишется в temp\logs\history.log.
rem FF_ARGS собирается вызывающим скриптом через !переменные!, поэтому
rem спецсимволы в путях и фильтрах не ломают командную строку.
rem ============================================================================
:RunFF
setlocal EnableDelayedExpansion
if not defined FF_ARGS (
    echo [ERROR] Внутренняя ошибка: FF_ARGS не задан.
    endlocal & exit /b 1
)
echo.
echo [CMD] ffmpeg !FFMPEG_GLOBAL_OPTIONS! !FF_ARGS!
echo.
>>"!HISTORY_FILE!" echo [!date! !time!] ffmpeg !FFMPEG_GLOBAL_OPTIONS! !FF_ARGS!
"!FFMPEG!" !FFMPEG_GLOBAL_OPTIONS! !FF_ARGS!
set "_rc=!errorlevel!"
>>"!HISTORY_FILE!" echo [exit !_rc!]
rem FFmpeg может вернуть отрицательный код (AVERROR): приводим к 0/1,
rem чтобы "if errorlevel 1" у вызывающего работал надёжно.
if not "!_rc!"=="0" (endlocal & exit /b 1)
endlocal & exit /b 0


rem ============================================================================
rem :RunJob
rem Подтверждение, запуск, вывод результата и предложение открыть файл.
rem Использует FF_ARGS и OUTPUT_FILE. Пути выводятся через !...!, поэтому
rem вызывающий скрипт должен работать с EnableDelayedExpansion (все
rem модули ToolKit так и делают).
rem errorlevel: 0 = успех, 1 = ошибка FFmpeg, 2 = отменено пользователем
rem ============================================================================
:RunJob
echo.
echo Выходной файл:
echo   !OUTPUT_FILE!
echo.
call :AskYN "Запустить обработку?" Y
if errorlevel 1 exit /b 2
call :RunFF
if errorlevel 1 (
    echo.
    echo [ERROR] FFmpeg завершился с ошибкой. Сообщение выше.
    echo         Команда сохранена в temp\logs\history.log
    echo.
    pause
    exit /b 1
)
echo.
echo ============================================================
echo   Готово
echo ============================================================
echo   !OUTPUT_FILE!
echo.
call :OfferOpen "%OUTPUT_FILE%"
exit /b 0


rem :ResetJob - очистить входные параметры lib\transcode.bat
:ResetJob
for %%V in (OUTPUT_SUFFIX OUTPUT_EXT OUTPUT_BASE INPUT_OPTS EXTRA_INPUTS VIDEO_FILTER AUDIO_FILTER FILTER_COMPLEX MAP_ARGS EXTRA_OUT_OPTS ENC_NO_VIDEO ENC_NO_AUDIO ENC_VIDEO_NO_COPY ENC_AUDIO_NO_COPY PREF_VIDEO PREF_AUDIO ENC_FIXED_ARGS JOB_TITLE FF_ARGS) do set "%%V="
exit /b 0


rem :OfferOpen "файл"
:OfferOpen
if not exist "%~1" (pause & exit /b 0)
set "_open="
if "%HAS_FFPLAY%"=="1" (
    set /p "_open=Открыть: P = FFplay, F = папка, Enter = нет: "
) else (
    set /p "_open=Открыть папку с результатом? F = да, Enter = нет: "
)
if not defined _open exit /b 0
if /i "%_open%"=="P" if "%HAS_FFPLAY%"=="1" "%FFPLAY%" %FFPLAY_GLOBAL_OPTIONS% -autoexit "%~1"
if /i "%_open%"=="F" explorer /select,"%~1"
set "_open="
exit /b 0


rem ============================================================================
rem Прочее
rem ============================================================================

rem :Timestamp VAR -> 2026-11-15_15-04-05 (формат зависит от локали, но
rem всегда безопасен для имени файла)
:Timestamp
set "_ts=%date%_%time%"
set "_ts=%_ts:/=-%"
set "_ts=%_ts::=-%"
set "_ts=%_ts:.=-%"
set "_ts=%_ts:,=-%"
set "_ts=%_ts: =0%"
set "%~1=%_ts%"
set "_ts="
exit /b 0

rem :ToMilli VAR "1.25" -> 1250
:ToMilli
set "_v=%~2"
if "%_v:~0,1%"=="." set "_v=0%_v%"
set "_i=0"
set "_f=000"
for /f "tokens=1,2 delims=." %%A in ("%_v%") do (
    set "_i=%%A"
    set "_f=%%B000"
)
set "_f=%_f:~0,3%"
set /a "%~1=_i*1000 + 1%_f% - 1000"
set "_v=" & set "_i=" & set "_f="
exit /b 0

rem :FromMilli VAR 1250 -> 1.250
:FromMilli
set /a "_i=%~2 / 1000, _f=%~2 %% 1000 + 1000"
set "%~1=%_i%.%_f:~1%"
set "_i=" & set "_f="
exit /b 0
