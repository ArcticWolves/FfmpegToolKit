@rem @label H.264 - Windows Media Foundation (встроен в Windows)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\h264_mf.bat
rem Обёртка над _mf.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_mf.bat" h264_mf %1
