# This script adds the Views filter to your project
# Run this with Visual Studio CLOSED

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ADDING VIEWS FILTER TO PROJECT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if VS is running
$vsProcess = Get-Process devenv -ErrorAction SilentlyContinue
if ($vsProcess) {
    Write-Host "ERROR: Visual Studio is running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "  1. Close Visual Studio" -ForegroundColor Yellow
    Write-Host "  2. Run this script again" -ForegroundColor Yellow
    Write-Host "  3. Reopen Visual Studio" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

$filtersFile = "ShootingBalloonV5.vcxproj.filters"

if (!(Test-Path $filtersFile)) {
    Write-Host "ERROR: Cannot find $filtersFile" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "[1/3] Creating backup..." -ForegroundColor Green
Copy-Item $filtersFile "$filtersFile.BACKUP" -Force
Write-Host "      Backup created: $filtersFile.BACKUP" -ForegroundColor Gray

Write-Host "[2/3] Reading current filters file..." -ForegroundColor Green
$content = Get-Content $filtersFile -Raw

# Check if Views filter already exists
if ($content -match '<Filter Include="Views">') {
    Write-Host ""
    Write-Host "Views filter already exists!" -ForegroundColor Yellow
    Write-Host "No changes needed." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host "[3/3] Adding Views filter..." -ForegroundColor Green

# Add Views filter definition after Include filter
$viewsFilterDef = @"
    <Filter Include="Views">
      <UniqueIdentifier>{F4G4J1H6-7I8J-9J2F-EH3G-6I9J1K2G3H4I}</UniqueIdentifier>
    </Filter>
"@

$content = $content -replace '(<Filter Include="Include">.*?</Filter>)', "`$1`r`n$viewsFilterDef"

# Update the MASM includes for Views files to use the Views filter
$content = $content -replace '<MASM Include="Src\\Views\\loading_screen\.asm" />', @"
<MASM Include="Src\Views\loading_screen.asm">
      <Filter>Views</Filter>
    </MASM>
"@

$content = $content -replace '<MASM Include="Src\\Views\\menu\.asm" />', @"
<MASM Include="Src\Views\menu.asm">
      <Filter>Views</Filter>
    </MASM>
"@

$content = $content -replace '<MASM Include="Src\\Views\\level_select\.asm" />', @"
<MASM Include="Src\Views\level_select.asm">
      <Filter>Views</Filter>
    </MASM>
"@

$content = $content -replace '<MASM Include="Src\\Views\\instructions\.asm" />', @"
<MASM Include="Src\Views\instructions.asm">
      <Filter>Views</Filter>
    </MASM>
"@

# Save updated content
Set-Content $filtersFile -Value $content -NoNewline

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   VIEWS FILTER ADDED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Changes made:" -ForegroundColor Cyan
Write-Host "  [+] Added Views filter definition" -ForegroundColor Gray
Write-Host "  [+] Organized UI files under Views filter:" -ForegroundColor Gray
Write-Host "      - loading_screen.asm" -ForegroundColor Gray
Write-Host "      - menu.asm" -ForegroundColor Gray
Write-Host "      - level_select.asm" -ForegroundColor Gray
Write-Host "      - instructions.asm" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open Visual Studio" -ForegroundColor White
Write-Host "  2. Check Solution Explorer" -ForegroundColor White
Write-Host "  3. You should see the Views filter!" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
