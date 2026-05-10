@echo off
cls

set /p QUERY=Введите строку поиска:

echo.
echo ===== Codecs =====
ffmpeg -codecs | findstr /i "%QUERY%"

echo.
echo ===== Encoders =====
ffmpeg -encoders | findstr /i "%QUERY%"

echo.
echo ===== Decoders =====
ffmpeg -decoders | findstr /i "%QUERY%"

echo.
echo ===== Filters =====
ffmpeg -filters | findstr /i "%QUERY%"

echo.
pause
exit /b