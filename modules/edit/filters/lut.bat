call "%SELECTORS_DIR%\select_lut.bat"

if not defined SELECTED_LUT (
    exit /b 1
)

set "VIDEO_FILTER=lut3d='%SELECTED_LUT%'"