@rem @label Apple ProRes (монтаж, большие файлы)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\prores_ks.bat
rem Встроенный энкодер prores_ks.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_p=3"
if /i not "%~1"=="auto" (
    echo   0 = Proxy, 1 = LT, 2 = Standard, 3 = HQ, 4 = 4444, 5 = 4444 XQ
    call "%LIB%" :AskInt _p "Профиль ProRes" 3 0 5
)
set "_pix=yuv422p10le"
if %_p% GEQ 4 set "_pix=yuva444p10le"
set "VIDEO_CODEC=prores_ks"
set "VIDEO_CODEC_OPTIONS=-profile:v %_p% -vendor apl0 -pix_fmt %_pix%"
