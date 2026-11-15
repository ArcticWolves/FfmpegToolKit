@rem @label H.264 - OpenH264 (CPU, базовое качество, есть в LGPL)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\libopenh264.bat
rem H.264 через libopenh264 (Cisco). Работает по битрейту.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
set "_b=6M"
if /i not "%~1"=="auto" call "%LIB%" :AskBitrate _b "Битрейт видео" 6M
set "VIDEO_CODEC=libopenh264"
set "VIDEO_CODEC_OPTIONS=-b:v %_b% -pix_fmt yuv420p"
