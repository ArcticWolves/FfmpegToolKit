@rem @label AV1 - NVIDIA NVENC (GPU, RTX 40+)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\av1_nvenc.bat
rem Обёртка над _nvenc.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_nvenc.bat" av1_nvenc %1
