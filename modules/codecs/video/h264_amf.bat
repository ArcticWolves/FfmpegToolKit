@rem @label H.264 - AMD AMF (GPU, быстро)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\h264_amf.bat
rem Обёртка над _amf.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_amf.bat" h264_amf %1
