@rem @label AV1 - Intel Quick Sync (GPU, Arc)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\av1_qsv.bat
rem Обёртка над _qsv.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_qsv.bat" av1_qsv %1
