@echo off
setlocal

set /p "HUE=Hue shift (degrees, default 0): "
set /p "SAT=Saturation (default 1.0): "

if not defined HUE set "HUE=0"
if not defined SAT set "SAT=1.0"

set "VF=hue=h=%HUE%:s=%SAT%"

"%FFMPEG%" %FFMPEG_GLOBAL_OPTIONS% ^
    -i "%INPUT_FILE%" ^
    -vf "%VF%" ^
    -c:v libx264 ^
    -c:a copy ^
    "%OUTPUT_FILE%"

endlocal
exit /b 0