@echo off
cls

if not defined CONFIG_LOADED (
    echo.
    echo [ERROR] Конфигурация не загружена.
    echo [ERROR] Запустите FFmpegToolKit.bat.
    echo.
    pause
    exit /b 1
)

set /p QUERY=Введите строку поиска:

echo.
echo ===== Codecs =====
"%FFMPEG%" -codecs | findstr /i "%QUERY%"

echo.
echo ===== Encoders =====
"%FFMPEG%" -encoders | findstr /i "%QUERY%"

echo.
echo ===== Decoders =====
"%FFMPEG%" -decoders | findstr /i "%QUERY%"

echo.
echo ===== Filters =====
"%FFMPEG%" -filters | findstr /i "%QUERY%"

echo.
pause
exit /b
