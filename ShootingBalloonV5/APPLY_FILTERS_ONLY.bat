@echo off
echo ========================================
echo   APPLY FILTERS-ONLY STRUCTURE
echo ========================================
echo.
echo This will reorganize your project to use
echo FILTERS ONLY (no physical folders).
echo.
echo IMPORTANT: Close Visual Studio first!
echo.
pause

REM Check if Visual Studio is closed
tasklist /FI "IMAGENAME eq devenv.exe" 2>NUL | find /I /N "devenv.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo.
    echo ERROR: Visual Studio is still running!
    echo Please close Visual Studio and run this script again.
    echo.
    pause
    exit /b 1
)

echo.
echo [1/5] Moving files to flat structure...
echo.

REM Move all .asm files to Src folder
if exist "Src\Views\*.asm" (
    echo   - Moving Views files...
    move "Src\Views\*.asm" "Src\" >nul 2>&1
)

if exist "Src\Audio\*.asm" (
    echo   - Moving Audio files...
    move "Src\Audio\*.asm" "Src\" >nul 2>&1
)

if exist "Src\Core\*.asm" (
    echo   - Moving Core files...
    move "Src\Core\*.asm" "Src\" >nul 2>&1
)

if exist "Src\GameLogic\*.asm" (
    echo   - Moving GameLogic files...
    move "Src\GameLogic\*.asm" "Src\" >nul 2>&1
)

if exist "Src\Initializer\*.asm" (
    echo   - Moving Initializer files...
    move "Src\Initializer\*.asm" "Src\" >nul 2>&1
)

if exist "Src\Input\*.asm" (
    echo   - Moving Input files...
    move "Src\Input\*.asm" "Src\" >nul 2>&1
)

if exist "Src\Renderer\*.asm" (
    echo   - Moving Renderer files...
    move "Src\Renderer\*.asm" "Src\" >nul 2>&1
)

echo.
echo [2/5] Removing empty physical folders...
echo.

if exist "Src\Views" (
    echo   - Removing Src\Views
    rmdir /s /q "Src\Views"
)
if exist "Src\Audio" (
    echo   - Removing Src\Audio
    rmdir /s /q "Src\Audio"
)
if exist "Src\Core" (
    echo   - Removing Src\Core
    rmdir /s /q "Src\Core"
)
if exist "Src\GameLogic" (
    echo   - Removing Src\GameLogic
    rmdir /s /q "Src\GameLogic"
)
if exist "Src\Initializer" (
    echo   - Removing Src\Initializer
    rmdir /s /q "Src\Initializer"
)
if exist "Src\Input" (
    echo   - Removing Src\Input
    rmdir /s /q "Src\Input"
)
if exist "Src\Renderer" (
    echo   - Removing Src\Renderer
    rmdir /s /q "Src\Renderer"
)
if exist "Src\UI" (
    echo   - Removing Src\UI
    rmdir /s /q "Src\UI"
)

echo.
echo [3/5] Backing up current filters file...
echo.
if exist "ShootingBalloonV5.vcxproj.filters" (
    copy "ShootingBalloonV5.vcxproj.filters" "ShootingBalloonV5.vcxproj.filters.BACKUP" >nul
    echo   - Backup created: ShootingBalloonV5.vcxproj.filters.BACKUP
)

echo.
echo [4/5] Applying new filters configuration...
echo.
if exist "ShootingBalloonV5.vcxproj.filters.UPDATED" (
    copy /Y "ShootingBalloonV5.vcxproj.filters.UPDATED" "ShootingBalloonV5.vcxproj.filters" >nul
    echo   - New filters applied
) else (
    echo   - ERROR: Updated filters file not found!
    echo   - Please apply filters manually using FILTERS_ONLY_GUIDE.txt
)

echo.
echo [5/5] Updating project file paths...
echo.

REM Use PowerShell to update .vcxproj file
powershell -Command "& { $content = Get-Content 'ShootingBalloonV5.vcxproj' -Raw; $content = $content -replace 'Src\\Audio\\', 'Src\\'; $content = $content -replace 'Src\\Core\\', 'Src\\'; $content = $content -replace 'Src\\GameLogic\\', 'Src\\'; $content = $content -replace 'Src\\Initializer\\', 'Src\\'; $content = $content -replace 'Src\\Input\\', 'Src\\'; $content = $content -replace 'Src\\Renderer\\', 'Src\\'; $content = $content -replace 'Src\\Views\\', 'Src\\'; Set-Content 'ShootingBalloonV5.vcxproj' -Value $content }"

if %ERRORLEVEL% EQU 0 (
    echo   - Project paths updated successfully
) else (
    echo   - Warning: Could not update paths automatically
    echo   - You may need to update paths manually in Visual Studio
)

echo.
echo ========================================
echo   REORGANIZATION COMPLETE! ?
echo ========================================
echo.
echo Physical folder structure:
echo   Src\
echo     ??? *.asm (all source files)
echo     ??? Include\
echo         ??? *.inc (header files)
echo.
echo Visual Studio will show FILTERS for organization:
echo   ?? Core
echo   ?? GameLogic  
echo   ?? Renderer
echo   ?? Input
echo   ?? Audio
echo   ?? Initializer
echo   ?? Views (NEW!)
echo   ?? Include
echo   ?? Documentation
echo   ?? Build Scripts
echo.
echo Next steps:
echo   1. Open Visual Studio
echo   2. Open ShootingBalloonV5.sln
echo   3. Check Solution Explorer - you should see filters!
echo   4. Build project (F7) to verify everything works
echo.
echo If you encounter any issues, see:
echo   FILTERS_ONLY_GUIDE.txt
echo.
echo ========================================
pause
