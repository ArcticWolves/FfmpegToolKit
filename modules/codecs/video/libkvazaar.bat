@rem @label HEVC - Kvazaar (CPU, есть в LGPL)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libkvazaar.bat
rem H.265/HEVC через libkvazaar. Работает по битрейту.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=4M"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт видео" 4M
set "_tag="
if /i "%TARGET_CONTAINER%"=="mp4" set "_tag= -tag:v hvc1"
if /i "%TARGET_CONTAINER%"=="mov" set "_tag= -tag:v hvc1"
set "VIDEO_CODEC=libkvazaar"
set "VIDEO_CODEC_OPTIONS=-b:v %_b% -pix_fmt yuv420p%_tag%"
