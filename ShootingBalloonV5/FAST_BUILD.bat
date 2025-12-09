@echo off
REM ========================================
REM  FAST BUILD & RUN SCRIPT
REM  Optimized for quick testing iterations
REM ========================================

echo.
echo ================================
echo   FAST BUILD AND RUN
echo ================================
echo.

REM Check if solution file exists
if not exist "ShootingBalloonV5.sln" (
    echo ERROR: ShootingBalloonV5.sln not found!
    echo Run this script from the project directory.
    pause
    exit /b 1
)

REM Clean previous build (optional - comment out for even faster builds)
REM echo [1/3] Cleaning old build...
REM del /Q *.obj 2>nul
REM del /Q *.exe 2>nul

REM Build the project
echo [1/2] Building project...
echo.

REM Try to use MSBuild from VS 2022
set MSBUILD_PATH="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"

if not exist %MSBUILD_PATH% (
    echo ERROR: MSBuild not found at expected location!
    echo Please update MSBUILD_PATH in this script.
    pause
    exit /b 1
)

REM Build with minimal verbosity for speed
%MSBUILD_PATH% ShootingBalloonV5.sln /t:Build /p:Configuration=Release /p:Platform=Win32 /v:minimal /m

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo   BUILD FAILED!
    echo ========================================
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ========================================
echo   BUILD SUCCESSFUL!
echo ========================================
echo.

REM Find the executable
set EXE_PATH=Release\ShootingBalloonV5.exe

if not exist "%EXE_PATH%" (
    set EXE_PATH=Debug\ShootingBalloonV5.exe
)

if not exist "%EXE_PATH%" (
    echo ERROR: Executable not found!
    echo Looked in Release\ and Debug\
    pause
    exit /b 1
)

REM Run the game
echo [2/2] Launching game...
echo.
echo Starting: %EXE_PATH%
echo.
echo ========================================
echo   GAME RUNNING
echo   Press any key after game exits...
echo ========================================
echo.

start "" "%EXE_PATH%"

REM Wait for game to start
timeout /t 1 /nobreak >nul

echo.
echo Game launched successfully!
echo.
pause
