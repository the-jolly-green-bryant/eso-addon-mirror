# =============================================================================
# Package DungeonTrialTracker for ESO Console Upload
# Run this script from the DungeonTrialTracker folder
# It creates a properly structured .zip ready for the Bethesda Uploader Tool
# =============================================================================

$addonName = "DungeonTrialTracker"
$outputZip = "..\${addonName}.zip"

# Remove old zip if exists
if (Test-Path $outputZip) {
    Remove-Item $outputZip -Force
    Write-Host "Removed old $outputZip" -ForegroundColor Yellow
}

# Create a temp staging folder with the addon name as subfolder
$stagingDir = "..\${addonName}_staging"
$stagingAddon = "$stagingDir\$addonName"

if (Test-Path $stagingDir) {
    Remove-Item $stagingDir -Recurse -Force
}

New-Item -ItemType Directory -Path $stagingAddon -Force | Out-Null

# Copy addon files (exclude dev/helper files)
$filesToInclude = @(
    "DungeonTrialTracker.addon",
    "DungeonTrialTracker.txt",
    "Bindings.xml",
    "DungeonTrialTrackerData.lua",
    "DungeonTrialTracker.lua",
    "DungeonTrialTrackerLocale.lua",
    "DungeonTrialTrackerUI.xml",
    "DungeonTrialTrackerUI.lua"
)

foreach ($file in $filesToInclude) {
    Copy-Item $file -Destination $stagingAddon
    Write-Host "  Added: $file" -ForegroundColor Green
}

# Create the zip
Compress-Archive -Path "$stagingDir\*" -DestinationPath $outputZip -Force
Write-Host ""
Write-Host "Created: $outputZip" -ForegroundColor Cyan

# Cleanup staging
Remove-Item $stagingDir -Recurse -Force

Write-Host ""
Write-Host "Done! Upload '$outputZip' using the Bethesda ESO AddOn Uploader Tool." -ForegroundColor Green
