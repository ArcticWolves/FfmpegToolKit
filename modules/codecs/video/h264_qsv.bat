@rem @label H.264 - Intel Quick Sync (GPU, быстро)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\h264_qsv.bat
rem Обёртка над _qsv.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_qsv.bat" h264_qsv %1
