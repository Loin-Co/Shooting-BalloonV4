# Add UI Files to Project - PowerShell Script
# Run this script to add the new UI modules to your Visual Studio project

Write-Host "Adding UI modules to ShootingBalloonV5 project..." -ForegroundColor Cyan

# Path to project file
$projectFile = "ShootingBalloonV5\ShootingBalloonV5.vcxproj"

# Check if project file exists
if (-not (Test-Path $projectFile)) {
    Write-Host "ERROR: Project file not found!" -ForegroundColor Red
    exit 1
}

# Read project file
$content = Get-Content $projectFile -Raw

# Check if UI files already added
if ($content -match "loading_screen\.asm") {
    Write-Host "UI files already added to project!" -ForegroundColor Yellow
    exit 0
}

# Find the last MASM Include line and add new files after it
$insertPoint = '    <MASM Include="Src\\Renderer\\render_core\.asm" />'
$newLines = @"
    <MASM Include="Src\Renderer\render_core.asm" />
    <MASM Include="Src\UI\loading_screen.asm" />
    <MASM Include="Src\UI\menu.asm" />
    <MASM Include="Src\UI\level_select.asm" />
"@

$content = $content -replace [regex]::Escape($insertPoint), $newLines

# Save updated project file
Set-Content $projectFile -Value $content -NoNewline

Write-Host "? Added UI modules to project file" -ForegroundColor Green

# Now update the filters file
$filtersFile = "ShootingBalloonV5\ShootingBalloonV5.vcxproj.filters"

if (Test-Path $filtersFile) {
    $filtersContent = Get-Content $filtersFile -Raw
    
    # Add UI filter if not exists
    if ($filtersContent -notmatch "<Filter Include=`"UI`">") {
        $filterInsert = '    <Filter Include="Initializer">'
        $newFilter = @"
    <Filter Include="UI">
      <UniqueIdentifier>{F4G4J1H6-7I8J-9J2F-EH3G-6I9J1K2G3H4I}</UniqueIdentifier>
    </Filter>
    <Filter Include="Initializer">
"@
        $filtersContent = $filtersContent -replace [regex]::Escape($filterInsert), $newFilter
    }
    
    # Add UI files to filters
    if ($filtersContent -notmatch "loading_screen\.asm") {
        $masmInsert = '    <MASM Include="Src\\Input\\input_mgr\.asm">'
        $newMasmFilters = @"
    <MASM Include="Src\Input\input_mgr.asm">
      <Filter>Input</Filter>
    </MASM>
    
    <!-- UI System -->
    <MASM Include="Src\UI\loading_screen.asm">
      <Filter>UI</Filter>
    </MASM>
    <MASM Include="Src\UI\menu.asm">
      <Filter>UI</Filter>
    </MASM>
    <MASM Include="Src\UI\level_select.asm">
      <Filter>UI</Filter>
    </MASM>
    
    <!-- Game Logic -->
    <MASM Include="Src\GameLogic\player.asm">
"@
        $filtersContent = $filtersContent -replace '    <MASM Include="Src\\Input\\input_mgr\.asm">\s+<Filter>Input</Filter>\s+</MASM>\s+<!-- Game Logic -->\s+<MASM Include="Src\\GameLogic\\player\.asm">', $newMasmFilters
    }
    
    Set-Content $filtersFile -Value $filtersContent -NoNewline
    Write-Host "? Updated filters file" -ForegroundColor Green
}

Write-Host ""
Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  UI FILES ADDED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Close Visual Studio if it's open"
Write-Host "2. Reopen the solution"
Write-Host "3. Build ? Clean Solution"
Write-Host "4. Build ? Rebuild Solution"
Write-Host "5. Press F5 to run!"
Write-Host ""
