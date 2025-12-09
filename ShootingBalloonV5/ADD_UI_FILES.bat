@echo off
echo.
echo ========================================
echo   ADDING UI FILES TO PROJECT
echo ========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PowerShell not found!
    echo Please add files manually - see UI_IMPLEMENTATION_COMPLETE.md
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -File "ADD_UI_FILES.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo SUCCESS! UI files added to project.
    echo.
    echo Please reload Visual Studio solution and rebuild.
) else (
    echo.
    echo FAILED to add files. Please add manually.
    echo See UI_IMPLEMENTATION_COMPLETE.md for instructions.
)

echo.
pause
