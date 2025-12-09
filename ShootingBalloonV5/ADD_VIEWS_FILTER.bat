@echo off
echo ========================================
echo    ADDING VIEWS FILTER TO PROJECT
echo ========================================
echo.
echo This script will add the Views filter to your project
echo and organize your UI files under it.
echo.
echo IMPORTANT: Close Visual Studio first!
echo.
pause

REM Check if VS is running
tasklist /FI "IMAGENAME eq devenv.exe" 2>NUL | find /I /N "devenv.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo.
    echo ERROR: Visual Studio is still running!
    echo.
    echo Please:
    echo   1. Close Visual Studio
    echo   2. Run this script again
    echo   3. Reopen Visual Studio
    echo.
    pause
    exit /b 1
)

echo.
echo Running PowerShell script to add Views filter...
echo.

PowerShell -ExecutionPolicy Bypass -File "ADD_VIEWS_FILTER.ps1"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo    SUCCESS!
    echo ========================================
    echo.
    echo The Views filter has been added.
    echo.
    echo Now open Visual Studio and check Solution Explorer.
    echo You should see the Views filter with your UI files!
    echo.
) else (
    echo.
    echo ========================================
    echo    ERROR!
    echo ========================================
    echo.
    echo Something went wrong. Please check the error messages above.
    echo.
)

pause
