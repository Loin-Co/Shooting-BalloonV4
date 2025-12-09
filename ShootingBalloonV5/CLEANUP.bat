@echo off
REM ========================================
REM  CLEANUP SCRIPT
REM  Removes build artifacts and temp files
REM ========================================

echo.
echo ================================
echo   PROJECT CLEANUP
echo ================================
echo.

echo Cleaning build artifacts...
echo.

REM Remove object files
if exist "*.obj" (
    echo [?] Removing .obj files...
    del /Q /F *.obj 2>nul
)

REM Remove executable files
if exist "*.exe" (
    echo [?] Removing .exe files...
    del /Q /F *.exe 2>nul
)

REM Remove debug database files
if exist "*.pdb" (
    echo [?] Removing .pdb files...
    del /Q /F *.pdb 2>nul
)

REM Remove incremental linking files
if exist "*.ilk" (
    echo [?] Removing .ilk files...
    del /Q /F *.ilk 2>nul
)

REM Remove listing files
if exist "*.lst" (
    echo [?] Removing .lst files...
    del /Q /F *.lst 2>nul
)

REM Remove Debug directory
if exist "Debug" (
    echo [?] Removing Debug\ directory...
    rd /S /Q Debug 2>nul
)

REM Remove Release directory
if exist "Release" (
    echo [?] Removing Release\ directory...
    rd /S /Q Release 2>nul
)

REM Remove x64 directory (if exists)
if exist "x64" (
    echo [?] Removing x64\ directory...
    rd /S /Q x64 2>nul
)

REM Remove .vs hidden directory (Visual Studio cache)
if exist ".vs" (
    echo [?] Removing .vs\ directory...
    rd /S /Q .vs 2>nul
)

REM Remove user-specific files
if exist "*.user" (
    echo [?] Removing .user files...
    del /Q /F *.user 2>nul
)

REM Remove temporary files
if exist "*.tmp" (
    echo [?] Removing .tmp files...
    del /Q /F *.tmp 2>nul
)

echo.
echo ================================
echo   CLEANUP COMPLETE!
echo ================================
echo.
echo Your project is now clean.
echo Next build will be a fresh build.
echo.
pause
