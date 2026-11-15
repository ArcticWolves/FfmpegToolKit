@echo off
rem ============================================================
rem modules\tools\screen_record.bat
rem Запись экрана (gdigrab), по желанию с микрофоном (dshow).
rem ============================================================

if not defined HAS_DEV_gdigrab (echo [ERROR] Устройство gdigrab отсутствует в сборке. & pause & exit /b 0)
call "%LIB%" :Header "Запись экрана"
call "%LIB%" :AskInt FPS "Кадров в секунду" 30 1 120
call "%LIB%" :AskTime DUR "Длительность (Enter = до нажатия q)" ""
set "AUDIO_IN="
call "%LIB%" :AskYN "Записывать звук с микрофона/линейного входа?" N
if not errorlevel 1 call :PickAudioDevice

set "STAMP="
call "%LIB%" :Timestamp STAMP
set "OUTPUT_FILE=%OUTPUT_DIR%\screen_%STAMP%.mkv"

rem Кодек: лучший доступный H.264 (аппаратный, если есть)
set "TARGET_CONTAINER=mkv"
set "PREF_VIDEO=h264_nvenc h264_qsv h264_amf h264_mf libx264 libopenh264"
set "PREF_AUDIO=aac"
set "ENC_SILENT=1"
call "%SELECTORS_DIR%\select_encoding.bat"

set "T="
if defined DUR set "T=-t %DUR%"
set "FF_ARGS=-f gdigrab -framerate %FPS% -draw_mouse 1 -i desktop !AUDIO_IN! %T% !ENC_ARGS! "!OUTPUT_FILE!""
call "%LIB%" :Header "Запись экрана"
echo Запись в MKV: при сбое файл остаётся читаемым.
echo Остановить запись: клавиша q в этом окне.
call "%LIB%" :RunJob
exit /b 0

:PickAudioDevice
echo.
echo Поиск аудиоустройств...
"%FFMPEG%" -hide_banner -list_devices true -f dshow -i dummy 2> "%TEMP_DIR%\dshow.txt"
set "AN=0"
findstr /c:"(audio)" "%TEMP_DIR%\dshow.txt" > "%TEMP_DIR%\dshow_audio.txt" 2>nul
for /f "usebackq delims=" %%L in ("%TEMP_DIR%\dshow_audio.txt") do (
    set "_l=%%L"
    call :AddAudioDevice
)
if %AN%==0 (echo Аудиоустройства не найдены - запись без звука. & pause & exit /b 0)
call "%LIB%" :AskInt AI "Номер устройства" 1 1 %AN%
call set "ADEV=%%ADEV_%AI%%%"
set "AUDIO_IN=-f dshow -i audio="!ADEV!""
exit /b 0

rem Строка вида: [dshow @ 0000] "Microphone (Realtek Audio)" (audio)
:AddAudioDevice
set "_l=!_l:*"=!"
set "_l=!_l:" (audio)=!"
set /a AN+=1
set "ADEV_%AN%=!_l!"
echo   %AN%. !_l!
exit /b 0
