@rem @label AV1 - SVT-AV1 (CPU, быстрый и качественный AV1)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libsvtav1.bat
rem AV1 через libsvtav1.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_q=32"
set "_p=6"
if /i not "%~1"=="auto" call "%LIB%" :AskInt _q "CRF 0-63, меньше = лучше" 32 0 63
if /i not "%~1"=="auto" call "%LIB%" :AskInt _p "Пресет 0-13, меньше = медленнее и лучше" 6 0 13
set "VIDEO_CODEC=libsvtav1"
set "VIDEO_CODEC_OPTIONS=-crf %_q% -preset %_p% -pix_fmt yuv420p"
