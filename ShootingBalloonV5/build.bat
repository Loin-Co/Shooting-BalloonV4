@echo off
REM Build script for ShootingBalloonV5 MASM32 project
REM Sets up proper include paths and builds all assembly files

setlocal

set PROJECT_DIR=%~dp0
set INCLUDE_DIR=%PROJECT_DIR%Src\Include
set OBJ_DIR=%PROJECT_DIR%Debug
set OUT_EXE=%PROJECT_DIR%Debug\ShootingBalloonV5.exe

echo ===============================================
echo Building IT: Welcome to Derry 2025
echo ===============================================

REM Create Debug directory if it doesn't exist
if not exist "%OBJ_DIR%" mkdir "%OBJ_DIR%"

REM Assemble all source files with include path
echo.
echo [1/10] Assembling main.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\main.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%main.asm"
if errorlevel 1 goto :error

echo [2/10] Assembling global_data.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\global_data.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Core\global_data.asm"
if errorlevel 1 goto :error

echo [3/10] Assembling sys_init.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\sys_init.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Initializer\sys_init.asm"
if errorlevel 1 goto :error

echo [4/10] Assembling render_core.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\render_core.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Renderer\render_core.asm"
if errorlevel 1 goto :error

echo [5/10] Assembling draw_shapes.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\draw_shapes.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Renderer\draw_shapes.asm"
if errorlevel 1 goto :error

echo [6/10] Assembling input_mgr.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\input_mgr.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Input\input_mgr.asm"
if errorlevel 1 goto :error

echo [7/10] Assembling player.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\player.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\GameLogic\player.asm"
if errorlevel 1 goto :error

echo [8/10] Assembling enemies.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\enemies.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\GameLogic\enemies.asm"
if errorlevel 1 goto :error

echo [9/10] Assembling collision.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\collision.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\GameLogic\collision.asm"
if errorlevel 1 goto :error

echo [10/10] Assembling audio_mgr.asm...
ml.exe /c /coff /Cp /Zi /Fo"%OBJ_DIR%\audio_mgr.obj" /I"%INCLUDE_DIR%" /W3 "%PROJECT_DIR%Src\Audio\audio_mgr.asm"
if errorlevel 1 goto :error

echo.
echo Linking...
link.exe /SUBSYSTEM:CONSOLE /ENTRY:start /OUT:"%OUT_EXE%" ^
    "%OBJ_DIR%\main.obj" ^
    "%OBJ_DIR%\global_data.obj" ^
    "%OBJ_DIR%\sys_init.obj" ^
    "%OBJ_DIR%\render_core.obj" ^
    "%OBJ_DIR%\draw_shapes.obj" ^
    "%OBJ_DIR%\input_mgr.obj" ^
    "%OBJ_DIR%\player.obj" ^
    "%OBJ_DIR%\enemies.obj" ^
    "%OBJ_DIR%\collision.obj" ^
    "%OBJ_DIR%\audio_mgr.obj" ^
    kernel32.lib user32.lib msvcrt.lib
if errorlevel 1 goto :error

echo.
echo ===============================================
echo Build successful!
echo Output: %OUT_EXE%
echo ===============================================
goto :end

:error
echo.
echo ===============================================
echo Build FAILED!
echo ===============================================
exit /b 1

:end
endlocal
