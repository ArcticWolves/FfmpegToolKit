@rem @label Avid DNxHR (монтаж, большие файлы)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\dnxhd.bat
rem Встроенный энкодер dnxhd в профилях DNxHR (любое разрешение).
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_p=dnxhr_hq"
if /i not "%~1"=="auto" call "%LIB%" :AskPick _p "Профиль dnxhr_lb/sq/hq/hqx/444" dnxhr_hq "dnxhr_lb dnxhr_sq dnxhr_hq dnxhr_hqx dnxhr_444"
set "_pix=yuv422p"
if /i "%_p%"=="dnxhr_hqx" set "_pix=yuv422p10le"
if /i "%_p%"=="dnxhr_444" set "_pix=yuv444p10le"
set "VIDEO_CODEC=dnxhd"
set "VIDEO_CODEC_OPTIONS=-profile:v %_p% -pix_fmt %_pix%"
