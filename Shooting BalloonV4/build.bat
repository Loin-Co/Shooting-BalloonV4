@echo off
REM Build script for IT: Welcome to Derry 2025
REM Zero-dependency build - no winmm.lib required!
echo Building IT: Welcome to Derry 2025...

if not exist Debug mkdir Debug

echo Assembling source files...
ml /c /coff /Zi /Fo"Debug\main.obj" main.asm
ml /c /coff /Zi /Fo"Debug\utils.obj" utils.asm
ml /c /coff /Zi /Fo"Debug\render.obj" render.asm
ml /c /coff /Zi /Fo"Debug\states.obj" states.asm
ml /c /coff /Zi /Fo"Debug\physics.obj" physics.asm
ml /c /coff /Zi /Fo"Debug\levels.obj" levels.asm

echo Linking...
link /SUBSYSTEM:CONSOLE /DEBUG /OUT:"Debug\ShootingBalloon.exe" ^
     Debug\main.obj Debug\utils.obj Debug\render.obj Debug\states.obj Debug\physics.obj Debug\levels.obj ^
     kernel32.lib user32.lib gdi32.lib

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build successful!
echo Zero-dependency achieved!
echo No winmm.lib required!
echo ========================================
echo Executable: Debug\ShootingBalloon.exe
pause
