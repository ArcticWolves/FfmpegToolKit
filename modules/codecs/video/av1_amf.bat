@rem @label AV1 - AMD AMF (GPU, RX 7000+)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\av1_amf.bat
rem Обёртка над _amf.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_amf.bat" av1_amf %1
