# ============================================================================
# migrate_to_modular.ps1 - Migration Script for Modular Structure
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "IT: Welcome to Derry 2025" -ForegroundColor Yellow
Write-Host "Modular Structure Migration Tool" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "Shooting BalloonV4_FIXED.vcxproj")) {
    Write-Host "ERROR: Please run this script from the project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "Choose migration option:" -ForegroundColor Green
Write-Host "1. Backup old files and switch to modular structure (RECOMMENDED)" -ForegroundColor White
Write-Host "2. Keep both old and new (for comparison)" -ForegroundColor White
Write-Host "3. Cancel" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host "`nCreating backup..." -ForegroundColor Yellow
        
        # Create backup directory
        $backupDir = "Backup_OldStructure_$(Get-Date -Format 'yyyy-MM-dd_HHmmss')"
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        
        # Backup old files
        $oldFiles = @(
            "main.asm",
            "physics.asm",
            "render.asm",
            "states.asm",
            "levels.asm",
            "utils.asm",
            "common.inc",
            "bindings.inc"
        )
        
        foreach ($file in $oldFiles) {
            if (Test-Path $file) {
                Copy-Item $file "$backupDir\" -Force
                Write-Host "  Backed up: $file" -ForegroundColor Gray
            }
        }
        
        Write-Host "  Backup complete: $backupDir" -ForegroundColor Green
        Write-Host ""
        
        Write-Host "Renaming old files..." -ForegroundColor Yellow
        foreach ($file in $oldFiles) {
            if (Test-Path $file) {
                Rename-Item $file "$file.OLD" -Force
                Write-Host "  Renamed: $file -> $file.OLD" -ForegroundColor Gray
            }
        }
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "Migration Complete!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Open IT_WelcomeToDerry_2025.vcxproj in Visual Studio" -ForegroundColor White
        Write-Host "2. Build the project (Ctrl+Shift+B)" -ForegroundColor White
        Write-Host "3. Run the game (Ctrl+F5)" -ForegroundColor White
        Write-Host ""
        Write-Host "Old files are backed up in: $backupDir" -ForegroundColor Gray
        Write-Host "Old files are renamed with .OLD extension" -ForegroundColor Gray
    }
    
    "2" {
        Write-Host "`nKeeping both structures..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Old project: Shooting BalloonV4_FIXED.vcxproj" -ForegroundColor White
        Write-Host "New project: IT_WelcomeToDerry_2025.vcxproj" -ForegroundColor White
        Write-Host ""
        Write-Host "WARNING: Cannot build both at the same time!" -ForegroundColor Red
        Write-Host "Open one project file at a time in Visual Studio." -ForegroundColor Yellow
    }
    
    "3" {
        Write-Host "`nMigration cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host "`nInvalid choice. Exiting." -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
