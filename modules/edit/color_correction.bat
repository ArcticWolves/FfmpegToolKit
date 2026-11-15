@echo off
rem ============================================================
rem modules\edit\color_correction.bat
rem Цветокоррекция: яркость/контраст, оттенок, температура, тонирование, LUT и др.
rem Входной файл (INPUT_FILE) уже выбран в edit.bat.
rem Запуск через общий движок lib\transcode.bat.
rem ============================================================

:MENU
call "%LIB%" :Header "Цветокоррекция"
echo   1. Яркость / контраст / насыщенность / гамма
echo   2. Оттенок и насыщенность (hue)
echo   3. Интенсивность и насыщенность (huesaturation)
echo   4. Цветовая температура (теплее / холоднее)
echo   5. Готовые тонировки (curves: винтаж, кросс-процесс...)
echo   6. LUT (.cube / .3dl) из папки luts
echo   7. Чёрно-белое
echo   8. Сепия
echo   9. Виньетка
echo   0. Назад
echo.
call "%LIB%" :AskChoice "Выберите фильтр"
set "VIDEO_FILTER="
if "%CHOICE%"=="1" goto EQ
if "%CHOICE%"=="2" goto HUE
if "%CHOICE%"=="3" goto HUESAT
if "%CHOICE%"=="4" goto TEMP
if "%CHOICE%"=="5" goto CURVES
if "%CHOICE%"=="6" goto LUT
if "%CHOICE%"=="7" (set "VIDEO_FILTER=hue=s=0" & set "OUTPUT_SUFFIX=bw" & goto RUN)
if "%CHOICE%"=="8" (set "VIDEO_FILTER=colorchannelmixer=.393:.769:.189:0:.349:.686:.168:0:.272:.534:.131" & set "OUTPUT_SUFFIX=sepia" & goto RUN)
if "%CHOICE%"=="9" goto VIGNETTE
if "%CHOICE%"=="0" exit /b 0
call "%LIB%" :InvalidChoice
goto MENU

:EQ
call "%LIB%" :AskNum B "Яркость, -1.0..1.0" 0
call "%LIB%" :AskNum C "Контраст, 0..3 (1 = без изменений)" 1
call "%LIB%" :AskNum S "Насыщенность, 0..3 (1 = без изменений)" 1
call "%LIB%" :AskNum G "Гамма, 0.1..10 (1 = без изменений)" 1
if defined HAS_FLT_eq (
    set "VIDEO_FILTER=eq=brightness=%B%:contrast=%C%:saturation=%S%:gamma=%G%"
) else (
    rem В LGPL-сборке нет фильтра eq: то же самое через lutyuv + hue
    set "VIDEO_FILTER=lutyuv=y='clip(pow(clip(((val-16)/219-0.5)*%C%+0.5+%B%,0,1),1/%G%)*219+16,16,235)',hue=s=%S%"
)
set "OUTPUT_SUFFIX=eq"
goto RUN

:HUE
call "%LIB%" :AskNum H "Сдвиг оттенка, градусы -180..180" 0
call "%LIB%" :AskNum S "Насыщенность, 0..10 (1 = без изменений)" 1
set "VIDEO_FILTER=hue=h=%H%:s=%S%"
set "OUTPUT_SUFFIX=hue"
goto RUN

:HUESAT
call "%LIB%" :AskNum I "Интенсивность, -1..1" 0
call "%LIB%" :AskNum S "Насыщенность, -1..1" 0
set "VIDEO_FILTER=huesaturation=intensity=%I%:saturation=%S%"
set "OUTPUT_SUFFIX=huesat"
goto RUN

:TEMP
echo   3200 = тёплый свет лампы, 6500 = дневной, 9000 = холодный
call "%LIB%" :AskInt K "Температура, K (1000-40000)" 5000 1000 40000
set "VIDEO_FILTER=colortemperature=temperature=%K%"
set "OUTPUT_SUFFIX=%K%K"
goto RUN

:CURVES
echo   vintage, cross_process, color_negative, negative, darker, lighter,
echo   increase_contrast, linear_contrast, medium_contrast, strong_contrast
call "%LIB%" :AskPick P "Пресет" vintage "vintage cross_process color_negative negative darker lighter increase_contrast linear_contrast medium_contrast strong_contrast"
set "VIDEO_FILTER=curves=preset=%P%"
set "OUTPUT_SUFFIX=%P%"
goto RUN

:LUT
call "%SELECTORS_DIR%\select_lut.bat"
if errorlevel 1 goto MENU
for %%F in ("%SELECTED_LUT%") do set "OUTPUT_SUFFIX=%%~nF"
set "LUT_PATH=%SELECTED_LUT%"
call "%LIB%" :FilterPath LUT_PATH
call "%LIB%" :AskInt STRENGTH "Сила LUT, процентов" 100 1 100
if %STRENGTH% GEQ 100 (
    set "VIDEO_FILTER=lut3d=file='!LUT_PATH!'"
) else (
    set /a "OP=STRENGTH"
    call "%LIB%" :FromMilli OPF !OP!0
    set "VIDEO_FILTER=split[a][b];[b]lut3d=file='!LUT_PATH!'[l];[a][l]blend=all_mode=normal:all_opacity=!OPF!"
)
goto RUN

:VIGNETTE
call "%LIB%" :AskPick V "Сила: light, medium, strong" medium "light medium strong"
set "ANGLE=PI/5"
if /i "%V%"=="light" set "ANGLE=PI/7"
if /i "%V%"=="strong" set "ANGLE=PI/3.5"
set "VIDEO_FILTER=vignette=angle=%ANGLE%"
set "OUTPUT_SUFFIX=vignette"
goto RUN

:RUN
set "JOB_TITLE=Цветокоррекция"
call "%TRANSCODE%"
exit /b 0
