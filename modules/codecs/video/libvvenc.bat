@rem @label H.266/VVC - VVenC (CPU, экспериментально, очень медленно)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libvvenc.bat
rem H.266/VVC через libvvenc. Поддерживается не всеми плеерами.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=32"
set "_p=fast"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "QP 0-63, меньше = лучше" 32 0 63
if /i not "%~1"=="auto" call "%LIB%" :AskPick _p "Пресет faster/fast/medium/slow/slower" fast "faster fast medium slow slower"
set "VIDEO_CODEC=libvvenc"
set "VIDEO_CODEC_OPTIONS=-qp %_q% -preset %_p% -pix_fmt yuv420p10le"
