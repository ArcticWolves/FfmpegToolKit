@echo off
rem ============================================================
rem modules\convert\pnm.bat
rem Профиль изображения: Netpbm (PBM / PGM / PPM)
rem Простые форматы Netpbm. Заменяет отдельные pbm/pgm/ppm/pnm.
rem Хуки для convert\_image.bat: args, settings.
rem ============================================================
if /i "%~1"=="args" goto ARGS
if /i "%~1"=="settings" goto SETTINGS

set "FORMAT_TITLE=Netpbm (PBM / PGM / PPM)"
set "OUTPUT_EXT=ppm"
set "HAS_SETTINGS=1"
set "P_T=ppm"
set "P_TH=50"
call "%MODULES_DIR%\convert\_image.bat" "%~f0"
exit /b %errorlevel%

:ARGS
if /i "%P_T%"=="pbm" (
    set "IMAGE_VF=format=gray,lut=y='if(gte(val,%P_TH%*255/100),255,0)'"
    set "IMAGE_ARGS=-c:v pbm"
    set "IMAGE_DESC=PBM (1 бит), порог %P_TH%%%"
)
if /i "%P_T%"=="pgm" (
    set "IMAGE_VF=format=gray"
    set "IMAGE_ARGS=-c:v pgm"
    set "IMAGE_DESC=PGM (оттенки серого)"
)
if /i "%P_T%"=="ppm" (
    set "IMAGE_ARGS=-c:v ppm"
    set "IMAGE_DESC=PPM (цвет)"
)
set "OUTPUT_EXT=%P_T%"
exit /b 0

:SETTINGS
call "%LIB%" :AskPick P_T "Тип: pbm (ч/б), pgm (серый), ppm (цвет)" %P_T% "pbm pgm ppm"
if /i "%P_T%"=="pbm" call "%LIB%" :AskInt P_TH "Порог чёрного/белого, процентов" %P_TH% 1 99
exit /b 0
