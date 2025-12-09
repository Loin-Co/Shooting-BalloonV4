@echo off
echo ========================================
echo  FOLDER CLEANUP - FILTERS ONLY MODE
echo ========================================
echo.
echo This script will move all source files to flat structure
echo and remove unnecessary physical folders.
echo.
echo IMPORTANT: Close Visual Studio before running!
echo.
pause

echo.
echo [1/8] Moving files from Src\Views to Src...
if exist "Src\Views\*.asm" move "Src\Views\*.asm" "Src\" >nul 2>&1

echo [2/8] Moving files from Src\Audio to Src...
if exist "Src\Audio\*.asm" move "Src\Audio\*.asm" "Src\" >nul 2>&1

echo [3/8] Moving files from Src\Core to Src...
if exist "Src\Core\*.asm" move "Src\Core\*.asm" "Src\" >nul 2>&1

echo [4/8] Moving files from Src\GameLogic to Src...
if exist "Src\GameLogic\*.asm" move "Src\GameLogic\*.asm" "Src\" >nul 2>&1

echo [5/8] Moving files from Src\Initializer to Src...
if exist "Src\Initializer\*.asm" move "Src\Initializer\*.asm" "Src\" >nul 2>&1

echo [6/8] Moving files from Src\Input to Src...
if exist "Src\Input\*.asm" move "Src\Input\*.asm" "Src\" >nul 2>&1

echo [7/8] Moving files from Src\Renderer to Src...
if exist "Src\Renderer\*.asm" move "Src\Renderer\*.asm" "Src\" >nul 2>&1

echo [8/8] Removing empty folders...
if exist "Src\Views" rmdir /s /q "Src\Views"
if exist "Src\Audio" rmdir /s /q "Src\Audio"
if exist "Src\Core" rmdir /s /q "Src\Core"
if exist "Src\GameLogic" rmdir /s /q "Src\GameLogic"
if exist "Src\Initializer" rmdir /s /q "Src\Initializer"
if exist "Src\Input" rmdir /s /q "Src\Input"
if exist "Src\Renderer" rmdir /s /q "Src\Renderer"
if exist "Src\UI" rmdir /s /q "Src\UI"

echo.
echo ========================================
echo  CLEANUP COMPLETE!
echo ========================================
echo.
echo Physical folders removed. Files are now in:
echo  - Src\        (all .asm files)
echo  - Src\Include (all .inc files)
echo.
echo Next steps:
echo  1. Apply the updated .vcxproj.filters file
echo  2. Reopen Visual Studio
echo  3. Project will show FILTERS ONLY (no physical folders)
echo.
echo ========================================
pause
