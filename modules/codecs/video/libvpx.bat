@rem @label VP8 - libvpx (CPU, старый WebM)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libvpx.bat
rem VP8 через libvpx (CRF с ограничением битрейта).
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=10"
set "_b=2M"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 4-63, меньше = лучше" 10 4 63
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Максимальный битрейт" 2M
set "VIDEO_CODEC=libvpx"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -b:v %_b% -pix_fmt yuv420p"
