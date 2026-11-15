@echo off
rem ============================================================
rem modules\tools\quality_compare.bat
rem Объективное сравнение качества: оригинал против перекодированной версии.
rem ============================================================

call "%LIB%" :Header "Сравнение качества"
echo Сначала выберите ОРИГИНАЛ, затем ОБРАБОТАННУЮ версию.
echo Разрешение обработанной версии приводится к оригиналу.
pause
set "INPUT_TITLE=Оригинал (эталон)"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
set "REF=%INPUT_FILE%"
call "%LIB%" :ProbeInput
set "INPUT_TITLE=Обработанная версия"
call "%SELECTORS_DIR%\select_input_file.bat"
if errorlevel 1 exit /b 0
set "DIST=%INPUT_FILE%"

echo.
if defined HAS_FLT_libvmaf (
    echo  1. VMAF  - оценка как у Netflix, 0-100   [Enter]
) else (
    echo  1. VMAF  - недоступен в этой сборке
)
echo  2. PSNR  - быстрая, в децибелах
echo  3. SSIM  - структурное сходство, 0-1
call "%LIB%" :AskChoice "Метрика"
set "M=%CHOICE%"
if not defined M set "M=1"
if "%M%"=="1" if not defined HAS_FLT_libvmaf set "M=2"
set "METRIC=libvmaf=n_threads=4"
if "%M%"=="2" set "METRIC=psnr"
if "%M%"=="3" set "METRIC=ssim"

rem Первый вход фильтра - проверяемое видео, второй - эталон
set "LOG=%LOG_DIR%\quality.txt"
set "FC=[1:v]scale=%IN_WIDTH%:%IN_HEIGHT%:flags=bicubic,setsar=1[d];[0:v]setsar=1[r];[d][r]%METRIC%"
echo.
echo [INFO] Анализ... (VMAF может занять время)
"%FFMPEG%" -hide_banner -nostats -i "%REF%" -i "%DIST%" -filter_complex "%FC%" -f null - 2> "%LOG%"
echo.
echo ============================================================
findstr /c:"VMAF score" /c:"PSNR y:" /c:"SSIM Y:" "%LOG%"
if errorlevel 1 (
    echo [ERROR] Не удалось получить результат. Журнал: %LOG%
) else (
    echo ============================================================
    echo VMAF: 95+ неотличимо, 80-95 хорошо, ниже 70 - заметные потери.
    echo PSNR: 40+ dB отлично, 30-40 нормально.  SSIM: 0.98+ отлично.
)
echo.
pause
