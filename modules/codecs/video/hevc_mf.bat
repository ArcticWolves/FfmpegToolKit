@rem @label HEVC - Windows Media Foundation (встроен в Windows)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\hevc_mf.bat
rem Обёртка над _mf.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_mf.bat" hevc_mf %1
