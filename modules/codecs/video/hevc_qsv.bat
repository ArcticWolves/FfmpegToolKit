@rem @label HEVC - Intel Quick Sync (GPU, быстро)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\hevc_qsv.bat
rem Обёртка над _qsv.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_qsv.bat" hevc_qsv %1
