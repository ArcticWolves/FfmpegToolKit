@rem @label H.264 - NVIDIA NVENC (GPU, быстро)
@echo off
rem ------------------------------------------------------------
rem modules\codecs\video\h264_nvenc.bat
rem Обёртка над _nvenc.bat.
rem %1 = auto  ->  без вопросов, значения по умолчанию.
rem Результат: VIDEO_CODEC, VIDEO_CODEC_OPTIONS
rem ------------------------------------------------------------
call "%~dp0_nvenc.bat" h264_nvenc %1
